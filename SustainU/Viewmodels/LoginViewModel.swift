import SwiftUI
import Auth0
import Combine

class LoginViewModel: ObservableObject {
    
    private var cancellables = Set<AnyCancellable>()

    
    static let shared = LoginViewModel()
    
    @Published var isAuthenticated: Bool = false
    @Published var userProfile: Profile = .empty
    @Published var isConnected: Bool = false
    @Published var showBackOnlineMessage: Bool = false // Nueva propiedad para mostrar el mensaje de "Back online"
    
    let connectivityManager = ConnectivityManager.shared

    private init() {
        connectivityManager.$isConnected
            .receive(on: RunLoop.main)
            .sink { [weak self] isConnected in
                self?.isConnected = isConnected
                if isConnected {
                    self?.showBackOnlineMessage = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        self?.showBackOnlineMessage = false
                    }
                }
            }
            .store(in: &cancellables) // Ahora debería reconocer "cancellables"
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
