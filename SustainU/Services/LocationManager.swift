import SwiftUI
import MapKit
import CoreLocation

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let locationManager = CLLocationManager()
    
    // Coordenadas de la Universidad de los Andes
    let uniAndesCoordinate = CLLocationCoordinate2D(latitude: 4.6014, longitude: -74.0655)
    
    @Published var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 4.6014, longitude: -74.0655), // Universidad de los Andes
        span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
    )
    
    @Published var userLocation: CLLocationCoordinate2D?
    @Published var location: CLLocation? // Added this property
    @Published var locationStatus: String = "Initializing..."

    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
    }

    func startUpdatingLocation() {
        print("Starting location updates")
        locationManager.startUpdatingLocation()
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        userLocation = location.coordinate
        self.location = location // Update the location property
        print("Location updated: \(location.coordinate.latitude), \(location.coordinate.longitude)")
        
        // Solo actualizamos la región si el usuario se ha movido significativamente
        let distanceFromUniAndes = CLLocation(latitude: uniAndesCoordinate.latitude, longitude: uniAndesCoordinate.longitude).distance(from: location)
        if distanceFromUniAndes > 1000 { // Si el usuario está a más de 1km de la universidad
            DispatchQueue.main.async {
                self.region = MKCoordinateRegion(
                    center: location.coordinate,
                    span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
                )
            }
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error: \(error.localizedDescription)")
        locationStatus = "Error: \(error.localizedDescription)"
    }

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .notDetermined:
            locationStatus = "Not Determined"
        case .authorizedWhenInUse, .authorizedAlways:
            locationStatus = "Authorized"
            startUpdatingLocation()
        case .restricted:
            locationStatus = "Restricted"
        case .denied:
            locationStatus = "Denied"
        @unknown default:
            locationStatus = "Unknown"
        }
        print("Location status: \(locationStatus)")
    }
}
