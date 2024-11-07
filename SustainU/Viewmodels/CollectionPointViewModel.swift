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
    
    private var db: Firestore
    private var listener: ListenerRegistration?
    private let monitor = NWPathMonitor()
    private let userDefaults = UserDefaults.standard
    
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
            // Procesar los documentos sin ordenar por ubicación si no hay conexión
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
            
            // Si no hay conexión, mostrar los puntos en orden por defecto (alfabético)
            if !self.hasInternetConnection {
                self.collectionPoints = points.sorted { $0.name < $1.name }
            } else {
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
        
        let query = db.collection("eventdb").whereField("name", isEqualTo: "MapView")
        query.getDocuments(source: .cache) { [weak self] (querySnapshot, error) in
            if let error = error {
                self?.incrementMapCountFromServer()
                return
            }
            
            if let document = querySnapshot?.documents.first {
                self?.updateMapCount(document: document)
            } else {
                self?.incrementMapCountFromServer()
            }
        }
    }
    
    private func incrementMapCountFromServer() {
        let query = db.collection("eventdb").whereField("name", isEqualTo: "MapView")
        
        query.getDocuments(source: .server) { [weak self] querySnapshot, error in
            if let error = error {
                print("Error getting documents: \(error)")
                return
            }
            
            if let document = querySnapshot?.documents.first {
                self?.updateMapCount(document: document)
            } else {
                self?.db.collection("counters").addDocument(data: [
                    "name": "MapView",
                    "count": 1
                ])
            }
        }
    }
    
    private func updateMapCount(document: QueryDocumentSnapshot) {
        document.reference.updateData([
            "count": FieldValue.increment(Int64(1))
        ]) { error in
            if let error = error {
                print("Error updating map count: \(error)")
            }
        }
    }
    
    deinit {
        listener?.remove()
        monitor.cancel()
    }
}
