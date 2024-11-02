import SwiftUI
import MapKit
import CoreLocation

class AppleMapCacheManager {
    static let shared = AppleMapCacheManager()
    private let fileManager = FileManager.default
    private let cacheDirectory: URL
    
    init() {
        let cachePath = fileManager.urls(for: .cachesDirectory, in: .userDomainMask)[0]
        cacheDirectory = cachePath.appendingPathComponent("MapCache")
        try? fileManager.createDirectory(at: cacheDirectory, withIntermediateDirectories: true)
    }
    
    func cacheMapRegion(_ region: MKCoordinateRegion, for mapView: MKMapView) {
        let options = MKMapSnapshotter.Options()
        options.region = region
        options.size = mapView.frame.size
        options.scale = UIScreen.main.scale
        options.mapType = .standard
        
        let snapshotter = MKMapSnapshotter(options: options)
        snapshotter.start { [weak self] (snapshot, error) in
            guard let self = self,
                  let snapshot = snapshot,
                  let fileName = self.fileNameFor(region: region) else { return }
            
            let fileURL = self.cacheDirectory.appendingPathComponent(fileName)
            
            if let data = snapshot.image.pngData() {
                try? data.write(to: fileURL)
            }
        }
    }
    
    func getCachedMap(for region: MKCoordinateRegion) -> UIImage? {
        guard let fileName = fileNameFor(region: region) else { return nil }
        let fileURL = cacheDirectory.appendingPathComponent(fileName)
        guard let data = try? Data(contentsOf: fileURL),
              let image = UIImage(data: data) else { return nil }
        return image
    }
    
    private func fileNameFor(region: MKCoordinateRegion) -> String? {
        return "map_\(region.center.latitude)_\(region.center.longitude)_\(region.span.latitudeDelta).png"
    }
}

