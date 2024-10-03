import SwiftUI
import MapKit
import CoreLocation


struct MapView: UIViewRepresentable {
    @ObservedObject var locationManager: LocationManager
    @Binding var userTrackingMode: MKUserTrackingMode
    var collectionPoints: [CollectionPoint]
    var onAnnotationTap: (CollectionPoint) -> Void

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
            compass.topAnchor.constraint(equalTo: mapView.safeAreaLayoutGuide.topAnchor, constant: 10),
            compass.trailingAnchor.constraint(equalTo: mapView.trailingAnchor, constant: -10),
            
            // Position the user tracking button below the compass
            userTrackingButton.topAnchor.constraint(equalTo: compass.bottomAnchor, constant: 10),
            userTrackingButton.trailingAnchor.constraint(equalTo: mapView.trailingAnchor, constant: -10)
        ])
        
        return mapView
    }

    func updateUIView(_ view: MKMapView, context: Context) {
        view.userTrackingMode = userTrackingMode
        updateAnnotations(from: view)
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
            var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKMarkerAnnotationView

            if annotationView == nil {
                annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                annotationView?.canShowCallout = true
            } else {
                annotationView?.annotation = annotation
            }

            annotationView?.glyphImage = UIImage(systemName: "recycle")
            annotationView?.markerTintColor = .green

            return annotationView
        }

        func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
            guard let coordinates = view.annotation?.coordinate else { return }
            if let collectionPoint = parent.collectionPoints.first(where: { $0.coordinate.latitude == coordinates.latitude && $0.coordinate.longitude == coordinates.longitude }) {
                parent.onAnnotationTap(collectionPoint)
            }
        }
    }
}
