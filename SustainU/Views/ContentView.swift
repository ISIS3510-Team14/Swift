import SwiftUI

struct ContentView: View {
    @StateObject private var loginViewModel = LoginViewModel.shared

    var body: some View {
        if loginViewModel.isAuthenticated {
            HomeView(userProfile: loginViewModel.userProfile)
        } else {
            LoginView(viewModel: loginViewModel)
        }
    }
}
