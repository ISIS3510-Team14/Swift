import SwiftUI
import MapKit
import CoreLocation

struct MapView: UIViewRepresentable {
    @ObservedObject var locationManager: LocationManager
    @Binding var userTrackingMode: MKUserTrackingMode
    var collectionPoints: [CollectionPoint]
    var onAnnotationTap: (CollectionPoint) -> Void
    @State private var hasInitiallyZoomed: Bool = false

    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        mapView.showsUserLocation = true
        mapView.isPitchEnabled = true
        mapView.isRotateEnabled = true
        
        // Add compass to the map
        let compass = MKCompassButton(mapView: mapView)
        compass.compassVisibility = .visible
        mapView.addSubview(compass)
        
        // Add user tracking button
        let userTrackingButton = MKUserTrackingButton(mapView: mapView)
        userTrackingButton.layer.backgroundColor = UIColor.white.cgColor
        userTrackingButton.layer.borderColor = UIColor.lightGray.cgColor
        userTrackingButton.layer.borderWidth = 1
        userTrackingButton.layer.cornerRadius = 5
        userTrackingButton.translatesAutoresizingMaskIntoConstraints = false
        mapView.addSubview(userTrackingButton)
        
        // Position the compass in the top-right corner
        compass.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            compass.topAnchor.constraint(equalTo: mapView.safeAreaLayoutGuide.topAnchor, constant: 100),
            compass.trailingAnchor.constraint(equalTo: mapView.trailingAnchor, constant: -10),
            
            // Position the user tracking button below the compass
            userTrackingButton.topAnchor.constraint(equalTo: compass.bottomAnchor, constant: 10),
            userTrackingButton.trailingAnchor.constraint(equalTo: mapView.trailingAnchor, constant: -10)
        ])
        
        return mapView
    }

    func updateUIView(_ view: MKMapView, context: Context) {
        updateAnnotations(from: view)
        
        // Center on user location only once when the view first loads
        if !hasInitiallyZoomed, let userLocation = locationManager.userLocation {
            zoomToUserLocation(mapView: view, userLocation: userLocation)
            DispatchQueue.main.async {
                self.hasInitiallyZoomed = true
            }
        }
        
        // Update tracking mode only if it's not .none
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

    private func zoomToUserLocation(mapView: MKMapView, userLocation: CLLocationCoordinate2D) {
        let region = MKCoordinateRegion(center: userLocation, latitudinalMeters: 500, longitudinalMeters: 500)
        mapView.setRegion(region, animated: true)
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, MKMapViewDelegate {
        var parent: MapView

        init(_ parent: MapView) {
            self.parent = parent
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

            // Set the custom image
            annotationView?.image = UIImage(named: "custom-pin-image")
           
            // Optionally, adjust the size of the image
            annotationView?.frame = CGRect(x: 0, y: 0, width: 40, height: 40)

            return annotationView
        }

        func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
            guard let coordinates = view.annotation?.coordinate else { return }
            if let collectionPoint = parent.collectionPoints.first(where: { $0.coordinate.latitude == coordinates.latitude && $0.coordinate.longitude == coordinates.longitude }) {
                parent.onAnnotationTap(collectionPoint)
            }
        }

        func mapView(_ mapView: MKMapView, didChange mode: MKUserTrackingMode, animated: Bool) {
            DispatchQueue.main.async {
                self.parent.userTrackingMode = mode
            }
        }
    }
}
