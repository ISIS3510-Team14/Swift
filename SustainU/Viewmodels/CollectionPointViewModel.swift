import SwiftUI
import MapKit
import FirebaseFirestore
import Network

class CollectionPointViewModel: ObservableObject {
    @Published var collectionPoints: [CollectionPoint] = []
    @Published var isLoading = false
    @Published var showConnectivityPopup = false
    @Published var isFirstLaunch = true
    @Published var hasInternetConnection = false
    @Published var isNavigatingFromMainMenu: Bool = false
    private var db: Firestore
    private var listener: ListenerRegistration?
    private let monitor = NWPathMonitor()
    private let userDefaults = UserDefaults.standard
    private let locationManager = LocationManager()
    
    init() {
        db = Firestore.firestore()
        isFirstLaunch = !userDefaults.bool(forKey: "hasLaunchedBeforeMap")
        setupNetworkMonitoring()
    }
    
    private func setupNetworkMonitoring() {
        monitor.pathUpdateHandler = { [weak self] path in
            DispatchQueue.main.async {
                self?.hasInternetConnection = path.status == .satisfied
                self?.handleConnectivityChange()
            }
        }
        let queue = DispatchQueue(label: "NetworkMonitor")
        monitor.start(queue: queue)
    }
    
    private func handleConnectivityChange() {
        if isFirstLaunch {
            if !hasInternetConnection {
                showConnectivityPopup = true
            } else {
                setupRealtimeListener()
            }
        } else {
            // No es primera vez, intentar cargar del cache primero
            loadFromCache()
            if hasInternetConnection {
                setupRealtimeListener()
            }
        }
    }
    
    private func loadFromCache() {
        db.collection("locationdb")
            .getDocuments(source: .cache) { [weak self] snapshot, error in
                if let error = error {
                    print("Error loading from cache: \(error)")
                    return
                }
                
                self?.processSnapshot(snapshot)
            }
    }
    
    private func setupRealtimeListener() {
        isLoading = true
        
        listener = db.collection("locationdb")
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self = self else { return }
                self.isLoading = false
                
                if let error = error {
                    print("Error getting documents: \(error)")
                    return
                }
                
                if self.isFirstLaunch {
                    self.userDefaults.set(true, forKey: "hasLaunchedBeforeMap")
                    self.isFirstLaunch = false
                }
                
                self.processSnapshot(snapshot)
            }
    }
    
    private func processSnapshot(_ snapshot: QuerySnapshot?) {
        guard let documents = snapshot?.documents else {
            print("No documents found")
            return
        }
        
        DispatchQueue.main.async {
            let points = documents.compactMap { document -> CollectionPoint? in
                let data = document.data()
                
                guard let name = data["name"] as? String,
                      let location = data["info1"] as? String,
                      let materials = data["info2"] as? String,
                      let coordinates = data["loc"] as? GeoPoint,
                      let imageName = data["img"] as? String,
                      let count = data["count"] as? Int else {
                    return nil
                }
                
                return CollectionPoint(
                    id: UUID(),
                    name: name,
                    location: location,
                    materials: materials,
                    latitude: coordinates.latitude,
                    longitude: coordinates.longitude,
                    imageName: imageName,
                    documentID: document.documentID,
                    count: count
                )
            }
            
            // Ordenar por distancia si hay ubicación disponible
            if let userLocation = self.locationManager.location?.coordinate {
                self.collectionPoints = points.sorted { point1, point2 in
                    let location1 = CLLocation(latitude: point1.latitude, longitude: point1.longitude)
                    let location2 = CLLocation(latitude: point2.latitude, longitude: point2.longitude)
                    let userCLLocation = CLLocation(latitude: userLocation.latitude, longitude: userLocation.longitude)
                    
                    return location1.distance(from: userCLLocation) < location2.distance(from: userCLLocation)
                }
            } else {
                // Si no hay ubicación disponible, mantener el orden original
                self.collectionPoints = points
            }
        }
    }
    
    func retryConnection() {
        if hasInternetConnection {
            showConnectivityPopup = false
            setupRealtimeListener()
        }
    }
    func incrementMapFromNavBar() {
        guard hasInternetConnection else { return }
        
        let documentId = "lgYlHUbaVdK2xSNsdUu2"
        let docRef = db.collection("eventdb").document(documentId)
        
        docRef.updateData([
            "NavBar": FieldValue.increment(Int64(1))
        ]) { error in
            if let error = error {
                print("Error updating NavBar count: \(error)")
            } else {
                print("Successfully incremented NavBar count")
            }
        }
    }

    func incrementMapFromMainMenu() {
        guard hasInternetConnection else { return }
        
        let documentId = "lgYlHUbaVdK2xSNsdUu2"
        let docRef = db.collection("eventdb").document(documentId)
        
        docRef.updateData([
            "MainMenu": FieldValue.increment(Int64(1))
        ]) { error in
            if let error = error {
                print("Error updating MainMenu count: \(error)")
            } else {
                print("Successfully incremented MainMenu count")
            }
        }
    }
    
    func incrementCount(for point: CollectionPoint) {
        let docRef = db.collection("locationdb").document(point.documentID)
        
        // Actualización optimista local
        if let index = self.collectionPoints.firstIndex(where: { $0.id == point.id }) {
            DispatchQueue.main.async {
                self.collectionPoints[index].count += 1
            }
        }
        
        // Solo actualizar en Firestore si hay conexión
        if hasInternetConnection {
            docRef.updateData([
                "count": FieldValue.increment(Int64(1))
            ]) { [weak self] error in
                if let error = error {
                    print("Error updating document: \(error)")
                    // Revertir la actualización local si falla
                    if let self = self,
                       let index = self.collectionPoints.firstIndex(where: { $0.id == point.id }) {
                        DispatchQueue.main.async {
                            self.collectionPoints[index].count -= 1
                        }
                    }
                }
            }
        }
    }
    
    func incrementMapCount() {
        guard hasInternetConnection else { return }
        
        // Get current hour in 24-hour format (0-23)
        let currentHour = Calendar.current.component(.hour, from: Date())
        let documentId = "lgYlHUbaVdK2xSNsdUu2"
        
        // Get direct reference to the document
        let docRef = db.collection("eventdb").document(documentId)
        
        // Try to get from cache first
        docRef.getDocument(source: .cache) { [weak self] (document, error) in
            if let error = error {
                self?.incrementMapCountFromServer(hour: currentHour, docRef: docRef)
                return
            }
            
            if let document = document {
                self?.updateMapCount(document: document, hour: currentHour)
            } else {
                self?.incrementMapCountFromServer(hour: currentHour, docRef: docRef)
            }
        }
    }
    
    private func incrementMapCountFromServer(hour: Int, docRef: DocumentReference) {
        docRef.getDocument(source: .server) { [weak self] document, error in
            if let error = error {
                print("Error getting document: \(error)")
                return
            }
            
            if let document = document {
                self?.updateMapCount(document: document, hour: hour)
            } else {
                print("Document does not exist")
            }
        }
    }
    
    private func updateMapCount(document: DocumentSnapshot, hour: Int) {
        // Convert hour to string to match the field name in Firestore
        let hourField = String(hour)
        
        document.reference.updateData([
            hourField: FieldValue.increment(Int64(1))
        ]) { error in
            if let error = error {
                print("Error updating map count for hour \(hour): \(error)")
            } else {
                print("Successfully incremented count for hour \(hour)")
            }
        }
    }
    
    deinit {
        listener?.remove()
        monitor.cancel()
    }
}
