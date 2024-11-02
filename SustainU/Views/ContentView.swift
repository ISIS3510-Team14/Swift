import SwiftUI

struct ContentView: View {
    @StateObject private var loginViewModel = LoginViewModel.shared

    var body: some View {
        NavigationView {
                HomeView(userProfile: loginViewModel.userProfile, isAuthenticated: $loginViewModel.isAuthenticated)
            }
        }
    }

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
        if loginViewModel.isAuthenticated {
            HomeView(userProfile: loginViewModel.userProfile)
        } else {
            LoginView(viewModel: loginViewModel)
        }
    }
}
