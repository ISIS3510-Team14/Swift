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
        db.collection("locations").getDocuments { snapshot, error in
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
                      let imageName = data["img"] as? String else {
                    return nil
                }
                
                let latitude = coordinates.latitude
                let longitude = coordinates.longitude
                
                return CollectionPoint(id: UUID(), name: name, location: location, materials: materials, latitude: latitude, longitude: longitude, imageName: imageName)
            }
        }
    }
}
