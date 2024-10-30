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
    static let shared = ConnectivityManager()
    private var monitor: NWPathMonitor
    private var queue = DispatchQueue(label: "NetworkMonitor")
    
    @Published var isConnected: Bool = false

    private init() {
        monitor = NWPathMonitor()
        monitor.pathUpdateHandler = { path in
            DispatchQueue.main.async {
                self.isConnected = path.status == .satisfied
            }
        }
        monitor.start(queue: queue)
    }

    // Método para re-verificar la conexión
    func checkConnection() {
        // Aquí podrías verificar el estado manualmente o reiniciar el monitor si es necesario.
        monitor.cancel() // Cancela el monitor existente
        monitor = NWPathMonitor() // Crea un nuevo monitor
        monitor.pathUpdateHandler = { path in
            DispatchQueue.main.async {
                self.isConnected = path.status == .satisfied
            }
        }
        monitor.start(queue: queue)
    }
}
