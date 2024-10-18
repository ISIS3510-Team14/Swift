import SwiftUI
import MapKit
import Combine

class MapViewModel: ObservableObject {
    @Published var userTrackingMode: MKUserTrackingMode = .none
    @Published var selectedPoint: CollectionPoint?
    @Published var isNavigatingToDetail = false
    @Published var hasInitiallyZoomed = false
    
    let locationManager: LocationManager
    var collectionPoints: [CollectionPoint] = []
    
    init(locationManager: LocationManager) {
        self.locationManager = locationManager
    }
    
    func startUpdatingLocation() {
        locationManager.startUpdatingLocation()
    }
    
    func handleAnnotationTap(_ point: CollectionPoint) {
        selectedPoint = point
        isNavigatingToDetail = true
    }
    
    func updateAnnotations(for mapView: MKMapView) {
        mapView.removeAnnotations(mapView.annotations)
        
        let annotations = collectionPoints.map { point -> MKPointAnnotation in
            let annotation = MKPointAnnotation()
            annotation.coordinate = point.coordinate
            annotation.title = point.name
            annotation.subtitle = point.materials
            return annotation
        }
        
        mapView.addAnnotations(annotations)
    }
    
    func zoomToUserLocation(mapView: MKMapView) {
        guard !hasInitiallyZoomed, let userLocation = locationManager.userLocation else { return }
        
        let region = MKCoordinateRegion(center: userLocation, latitudinalMeters: 500, longitudinalMeters: 500)
        mapView.setRegion(region, animated: true)
        
        DispatchQueue.main.async {
            self.hasInitiallyZoomed = true
        }
    }
}
