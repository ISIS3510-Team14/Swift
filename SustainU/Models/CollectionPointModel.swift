import SwiftUI
import MapKit
import FirebaseFirestore

struct CollectionPoint: Identifiable {
    let id: UUID
    let name: String
    let location: String
    let materials: String
    let latitude: Double
    let longitude: Double
    let imageName: String
    let documentID: String
    var count: Int
    let info3: [String]  // Agregar esta línea

    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}
