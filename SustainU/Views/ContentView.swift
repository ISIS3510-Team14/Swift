import SwiftUI

struct ContentView: View {
    // Usar la instancia Singleton de LoginViewModel
    @StateObject private var loginViewModel = LoginViewModel.shared
    
    var body: some View {
        NavigationView {
            if loginViewModel.isAuthenticated {
                HomeView(userProfile: loginViewModel.userProfile, isAuthenticated: $loginViewModel.isAuthenticated)
            } else {
                LoginView(viewModel: loginViewModel)
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
