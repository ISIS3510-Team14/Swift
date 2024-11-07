import SwiftUI
import MapKit
import Combine
import Network

class MapViewModel: ObservableObject {
    @Published var userTrackingMode: MKUserTrackingMode = .none
    @Published var selectedPoint: CollectionPoint?
    @Published var isNavigatingToDetail = false
    @Published var hasInitiallyZoomed = false
    @Published var showOfflinePopup = false
    @Published var isOffline = false
    
    let locationManager: LocationManager
    var collectionPoints: [CollectionPoint] = []
    private let connectivityMonitor = NWPathMonitor()
    private var cancellables = Set<AnyCancellable>()
    
    init(locationManager: LocationManager) {
        self.locationManager = locationManager
        setupConnectivityMonitoring()
    }
    
    private func setupConnectivityMonitoring() {
        let queue = DispatchQueue(label: "NetworkMonitor")
        connectivityMonitor.pathUpdateHandler = { [weak self] path in
            DispatchQueue.main.async {
                self?.isOffline = path.status != .satisfied
                if self?.isOffline == true {
                    self?.showOfflinePopup = true
                }
            }
        }
        connectivityMonitor.start(queue: queue)
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
    
    deinit {
        connectivityMonitor.cancel()
    }
}
