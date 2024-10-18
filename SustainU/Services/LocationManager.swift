import SwiftUI
import MapKit
import CoreLocation

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let locationManager = CLLocationManager()
    @Published var userLocation: CLLocationCoordinate2D?
    @Published var location: CLLocation?
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
        print("New location: \(location)")
        self.location = location
        self.userLocation = location.coordinate
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
