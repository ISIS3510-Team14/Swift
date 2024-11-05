import Foundation
import Network
import Combine

class ConnectivityManager: ObservableObject {
    static let shared = ConnectivityManager()
    private var monitor: NWPathMonitor
    private var queue = DispatchQueue(label: "NetworkMonitor")

    @Published var isConnected: Bool = true

    private init() {
        monitor = NWPathMonitor()
        monitor.pathUpdateHandler = { path in
            let isConnected = path.status == .satisfied
            print("ConnectivityManager: isConnected = \(isConnected)")
            DispatchQueue.main.async {
                self.isConnected = isConnected
            }
        }
        monitor.start(queue: queue)
    }

}
