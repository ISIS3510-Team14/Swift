import SwiftUI

struct ContentView: View {
    // Crear una instancia del ViewModel
    @StateObject private var loginViewModel = LoginViewModel()
    
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
