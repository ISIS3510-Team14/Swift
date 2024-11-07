import MapKit
import CoreLocation

class OfflineMapManager {
    static let shared = OfflineMapManager()
    
    // Hacemos el cache internal para que sea accesible dentro del mismo módulo
    let cache: URLCache
    
    private init() {
        self.cache = URLCache(memoryCapacity: 20 * 1024 * 1024,
                            diskCapacity: 100 * 1024 * 1024,
                            diskPath: "offline_maps")
    }
    
    func cacheMapRegion(for region: MKCoordinateRegion) {
        let tiles = getTileCoordinates(for: region, minZoom: 13, maxZoom: 16)
        for tile in tiles {
            cacheTile(x: tile.x, y: tile.y, zoom: tile.zoom)
        }
    }
    
    private func cacheTile(x: Int, y: Int, zoom: Int) {
        let urlTemplate = "http://tile.openstreetmap.org/\(zoom)/\(x)/\(y).png"
        guard let url = URL(string: urlTemplate) else { return }
        
        let request = URLRequest(url: url)
        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            guard let response = response else { return }
            if let data = data {
                let cachedResponse = CachedURLResponse(response: response, data: data)
                self?.cache.storeCachedResponse(cachedResponse, for: request)
            }
        }.resume()
    }
    
    private func getTileCoordinates(for region: MKCoordinateRegion, minZoom: Int, maxZoom: Int) -> [(x: Int, y: Int, zoom: Int)] {
        var tiles: [(x: Int, y: Int, zoom: Int)] = []
        
        for zoom in minZoom...maxZoom {
            let tiles1 = getTilesFor(region: region, zoom: zoom)
            tiles.append(contentsOf: tiles1)
        }
        
        return tiles
    }
    
    private func getTilesFor(region: MKCoordinateRegion, zoom: Int) -> [(x: Int, y: Int, zoom: Int)] {
        let n = Double(1 << zoom)
        let lat_rad = region.center.latitude * .pi / 180.0
        let x = Int((region.center.longitude + 180.0) / 360.0 * n)
        let y = Int((1.0 - asinh(tan(lat_rad)) / .pi) / 2.0 * n)
        
        return [(x: x, y: y, zoom: zoom)]
    }
    
    // Método para limpiar el cache si es necesario
    func clearCache() {
        cache.removeAllCachedResponses()
    }
}

class CachedTileOverlay: MKTileOverlay {
    override init(urlTemplate URLTemplate: String?) {
        super.init(urlTemplate: URLTemplate)
        self.canReplaceMapContent = true
    }
    
    override func loadTile(at path: MKTileOverlayPath,
                          result: @escaping (Data?, Error?) -> Void) {
        let url = URL(string: "http://tile.openstreetmap.org/\(path.z)/\(path.x)/\(path.y).png")!
        let request = URLRequest(url: url)
        
        // Usar el cache del OfflineMapManager
        if let cachedResponse = OfflineMapManager.shared.cache.cachedResponse(for: request) {
            result(cachedResponse.data, nil)
            return
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                result(nil, error)
                return
            }
            
            if let data = data, let response = response {
                let cachedResponse = CachedURLResponse(response: response, data: data)
                OfflineMapManager.shared.cache.storeCachedResponse(cachedResponse, for: request)
                result(data, nil)
            }
        }.resume()
    }
}
