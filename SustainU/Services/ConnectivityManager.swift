//
//  ConnectivityManager.swift
//  SustainU
//
//  Created by Duarte Mantilla Ernesto Jose on 29/10/24.
//
import Foundation
import Network
import Combine

class ConnectivityManager: ObservableObject {
    // Singleton instance
    static let shared = ConnectivityManager()
    
    // Observable property to detect connection status
    @Published var isConnected: Bool = true

    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "NetworkMonitor")

    private init() {
        monitor.pathUpdateHandler = { path in
            DispatchQueue.main.async {
                self.isConnected = (path.status == .satisfied)
            }
        }
        monitor.start(queue: queue)
    }
}
