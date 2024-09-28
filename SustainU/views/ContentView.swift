import SwiftUI

struct ContentView: View {
    @State private var isAuthenticated = false
    @State private var userProfile = Profile.empty

    var body: some View {
        NavigationView {
            if isAuthenticated {
                HomeView(userProfile: userProfile, isAuthenticated: $isAuthenticated)  // Pasa ambos argumentos
            } else {
                LoginView(isAuthenticated: $isAuthenticated, userProfile: $userProfile)
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
