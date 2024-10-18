import SwiftUI
import MapKit

struct CollectionPoint: Identifiable {
    let id = UUID()
    let name: String
    let location: String
    let materials: String
    let latitude: Double
    let longitude: Double
    let imageName: String

    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }

    static let `default` = CollectionPoint(
        name: "",
        location: "",
        materials: "",
        latitude: 0,
        longitude: 0,
        imageName: "default-image"
    )
}
