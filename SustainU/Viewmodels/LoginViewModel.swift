import SwiftUI
import Auth0

class LoginViewModel: ObservableObject {
    static let shared = LoginViewModel() // Singleton
    
    @Published var isAuthenticated: Bool = false
    @Published var userProfile: Profile = .empty
    @Published var isConnected: Bool = false  // Nueva propiedad para el estado de conexión
    
    private let connectivityManager = ConnectivityManager.shared // Suponiendo que tienes un singleton aquí
    
    private init() {
        // Observa los cambios de conexión
        connectivityManager.$isConnected
            .receive(on: RunLoop.main)
            .assign(to: &$isConnected)
    }
    
    func authenticate() {
        Auth0
            .webAuth()
            .start { result in
                switch result {
                case .failure(let error):
                    print("Failed with: \(error)")
                case .success(let credentials):
                    self.isAuthenticated = true
                    self.userProfile = Profile.from(credentials.idToken)
                    print("User profile: \(self.userProfile)")
                    self.saveSession(credentials.idToken) // Guardar sesión en el inicio de sesión exitoso
                }
            }
    }
    
    func logout() {
        if NetworkMonitor.shared.isConnected {
            // Logout en línea a través de Auth0
            Auth0
                .webAuth()
                .clearSession(federated: false) { result in
                    switch result {
                    case .success:
                        self.clearLocalSession()
                    case .failure(let error):
                        print("Failed with: \(error)")
                    }
                }
        } else {
            // Logout sin conexión
            clearLocalSession()
        }
    }
    
    private func saveSession(_ idToken: String) {
        KeychainService.saveToken(idToken)
        KeychainService.saveProfile(self.userProfile)
    }
    
    func loadSession() {
        if let token = KeychainService.loadToken() {
            self.isAuthenticated = true
            self.userProfile = KeychainService.loadProfile() ?? .empty
        }
    }
    
    func clearLocalSession() {
        KeychainService.deleteToken()
        KeychainService.deleteProfile()
        self.isAuthenticated = false
        self.userProfile = .empty
    }
}
