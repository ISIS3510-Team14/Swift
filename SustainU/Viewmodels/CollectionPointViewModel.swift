import SwiftUI
import MapKit
import FirebaseFirestore

class CollectionPointViewModel: ObservableObject {
    @Published var collectionPoints: [CollectionPoint] = []
    @Published var isLoading = false
    
    private var db: Firestore
    private var listener: ListenerRegistration?
    
    init() {
        // Configurar la base de datos
        db = Firestore.firestore()
        
        // Iniciar el listener en tiempo real
        setupRealtimeListener()
        
        // Cargar datos del cache primero
        loadFromCache()
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
                
                self.processSnapshot(snapshot)
            }
    }
    
    private func processSnapshot(_ snapshot: QuerySnapshot?) {
        guard let documents = snapshot?.documents else {
            print("No documents found")
            return
        }
        
        DispatchQueue.main.async {
            self.collectionPoints = documents.compactMap { document -> CollectionPoint? in
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
        
        // Actualizar en Firestore
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
    
    func incrementMapCount() {
        let query = db.collection("eventdb").whereField("name", isEqualTo: "MapView")
        
        // Intentar primero desde el cache
        query.getDocuments(source: .cache) { [weak self] (querySnapshot, error) in
            if let error = error {
                // Si falla el cache, intentar desde el servidor
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
                // Crear nuevo documento si no existe
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
        // Remover el listener cuando se destruye el ViewModel
        listener?.remove()
    }
}
