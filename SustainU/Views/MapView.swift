import SwiftUI
import MapKit
import CoreLocation

struct MapViewWithOfflinePopup: View {
    @ObservedObject var locationManager: LocationManager
    @Binding var userTrackingMode: MKUserTrackingMode
    var collectionPoints: [CollectionPoint]
    var onAnnotationTap: (CollectionPoint) -> Void
    @StateObject private var viewModel = MapViewModel(locationManager: LocationManager())
    
    var body: some View {
        ZStack {
            MapView(locationManager: locationManager,
                   userTrackingMode: $userTrackingMode,
                   collectionPoints: collectionPoints,
                   onAnnotationTap: onAnnotationTap,
                   viewModel: viewModel)
                .onTapGesture {
                    viewModel.handleMapTap()
                }
            
            if viewModel.showOfflinePopup {
                OfflineMapPopupView(isPresented: $viewModel.showOfflinePopup)
            }
        }
    }
}

struct MapView: UIViewRepresentable {
    @ObservedObject var locationManager: LocationManager
    @Binding var userTrackingMode: MKUserTrackingMode
    var collectionPoints: [CollectionPoint]
    var onAnnotationTap: (CollectionPoint) -> Void
    @ObservedObject var viewModel: MapViewModel
    
    init(locationManager: LocationManager,
         userTrackingMode: Binding<MKUserTrackingMode>,
         collectionPoints: [CollectionPoint],
         onAnnotationTap: @escaping (CollectionPoint) -> Void,
         viewModel: MapViewModel) {
        self.locationManager = locationManager
        self._userTrackingMode = userTrackingMode
        self.collectionPoints = collectionPoints
        self.onAnnotationTap = onAnnotationTap
        self.viewModel = viewModel
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        mapView.showsUserLocation = true
        mapView.isPitchEnabled = true
        mapView.isRotateEnabled = true
        mapView.mapType = .standard
        
        let tapGesture = UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleMapTap(_:)))
        mapView.addGestureRecognizer(tapGesture)
        
        let compass = MKCompassButton(mapView: mapView)
        compass.compassVisibility = .visible
        mapView.addSubview(compass)
        
        let userTrackingButton = MKUserTrackingButton(mapView: mapView)
        userTrackingButton.layer.backgroundColor = UIColor.white.cgColor
        userTrackingButton.layer.borderColor = UIColor.lightGray.cgColor
        userTrackingButton.layer.borderWidth = 1
        userTrackingButton.layer.cornerRadius = 5
        userTrackingButton.translatesAutoresizingMaskIntoConstraints = false
        mapView.addSubview(userTrackingButton)
        
        compass.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            compass.topAnchor.constraint(equalTo: mapView.safeAreaLayoutGuide.topAnchor, constant: 100),
            compass.trailingAnchor.constraint(equalTo: mapView.trailingAnchor, constant: -10),
            userTrackingButton.topAnchor.constraint(equalTo: compass.bottomAnchor, constant: 10),
            userTrackingButton.trailingAnchor.constraint(equalTo: mapView.trailingAnchor, constant: -10)
        ])
        
        return mapView
    }
    
    func updateUIView(_ view: MKMapView, context: Context) {
        updateAnnotations(from: view)
        
        if !viewModel.hasInitiallyZoomed, let userLocation = locationManager.userLocation {
            let region = MKCoordinateRegion(
                center: userLocation,
                latitudinalMeters: 500,
                longitudinalMeters: 500
            )
            view.setRegion(region, animated: true)
            
            AppleMapCacheManager.shared.cacheMapRegion(region, for: view)
            
            DispatchQueue.main.async {
                viewModel.hasInitiallyZoomed = true
            }
        }
        
        if userTrackingMode != .none {
            view.setUserTrackingMode(userTrackingMode, animated: true)
        }
    }
    
    private func updateAnnotations(from mapView: MKMapView) {
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
    
    class Coordinator: NSObject, MKMapViewDelegate {
        var parent: MapView
        
        init(_ parent: MapView) {
            self.parent = parent
        }
        
        @objc func handleMapTap(_ gesture: UITapGestureRecognizer) {
            parent.viewModel.handleMapTap()
        }
        
        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            guard !(annotation is MKUserLocation) else { return nil }
            
            let identifier = "CollectionPoint"
            var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
            
            if annotationView == nil {
                annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                annotationView?.canShowCallout = true
                
                let infoButton = UIButton(type: .detailDisclosure)
                annotationView?.rightCalloutAccessoryView = infoButton
            } else {
                annotationView?.annotation = annotation
            }
            
            annotationView?.image = UIImage(named: "custom-pin-image")
            annotationView?.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
            
            return annotationView
        }
        
        func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
            guard let coordinates = view.annotation?.coordinate else { return }
            if let collectionPoint = parent.collectionPoints.first(where: {
                $0.coordinate.latitude == coordinates.latitude &&
                $0.coordinate.longitude == coordinates.longitude
            }) {
                DispatchQueue.main.async {
                    self.parent.onAnnotationTap(collectionPoint)
                }
            }
        }
        
        func mapView(_ mapView: MKMapView, didChange mode: MKUserTrackingMode, animated: Bool) {
            DispatchQueue.main.async {
                self.parent.userTrackingMode = mode
            }
        }
        
        func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
            AppleMapCacheManager.shared.cacheMapRegion(mapView.region, for: mapView)
        }
    }
    
    static func dismantleUIView(_ uiView: MKMapView, coordinator: Coordinator) {
        uiView.removeFromSuperview()
    }
}
