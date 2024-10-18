import SwiftUI
import Auth0

class LoginViewModel: ObservableObject {
    @Published var isAuthenticated: Bool = false
    @Published var userProfile: Profile = .empty
    
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
                }
            }
    }
}
