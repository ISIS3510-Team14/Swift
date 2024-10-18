import SwiftUI
import MapKit
import FirebaseFirestore


class CollectionPointViewModel: ObservableObject {
    @Published var collectionPoints: [CollectionPoint] = []
    
    private var db = Firestore.firestore()
    
    init() {
        fetchCollectionPoints()
    }
    
    func fetchCollectionPoints() {
        db.collection("locationdb").getDocuments { snapshot, error in
            if let error = error {
                print("Error getting documents: \(error)")
                return
            }
            
            guard let documents = snapshot?.documents else {
                print("No documents found")
                return
            }
            
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
                
                let latitude = coordinates.latitude
                let longitude = coordinates.longitude
                
                return CollectionPoint(id: UUID(), name: name, location: location, materials: materials, latitude: latitude, longitude: longitude, imageName: imageName, documentID: document.documentID, count: count)
            }
        }
    }
    
    func incrementCount(for point: CollectionPoint) {
        let docRef = db.collection("locationdb").document(point.documentID)
        print(docRef)
        
        docRef.updateData([
            "count": FieldValue.increment(Int64(1))
        ]) { error in
            if let error = error {
                print("Error updating document: \(error)")
            } else {
                print("Document successfully updated")
                // Update the local collection point
                if let index = self.collectionPoints.firstIndex(where: { $0.id == point.id }) {
                    self.collectionPoints[index].count += 1
                }
            }
        }
    }
    func incrementMapCount() {
        let query = db.collection("eventdb").whereField("name", isEqualTo: "MapView")
        
        query.getDocuments { (querySnapshot, error) in
            if let error = error {
                print("Error getting documents: \(error)")
                return
            }
            
            guard let document = querySnapshot?.documents.first else {
                print("No matching documents")
                // If no document exists, create one
                self.db.collection("counters").addDocument(data: [
                    "name": "MapView",
                    "count": 1
                ]) { error in
                    if let error = error {
                        print("Error creating map count document: \(error)")
                    } else {
                        print("Map count document successfully created")
                    }
                }
                return
            }
            
            // Document exists, update the count
            document.reference.updateData([
                "count": FieldValue.increment(Int64(1))
            ]) { error in
                if let error = error {
                    print("Error updating map count: \(error)")
                } else {
                    print("Map count successfully updated")
                }
            }}}
}
