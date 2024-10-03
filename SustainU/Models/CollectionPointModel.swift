import SwiftUI
import MapKit

struct CollectionPoint: Identifiable {
    let id = UUID()
    let name: String
    let location: String
    let materials: String
    let latitude: Double
    let longitude: Double
    
    var coordinate: CLLocationCoordinate2D{
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}
