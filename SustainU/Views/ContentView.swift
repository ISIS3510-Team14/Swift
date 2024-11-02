import SwiftUI

struct ContentView: View {
    @StateObject private var loginViewModel = LoginViewModel.shared

    var body: some View {
            HomeView(userProfile: loginViewModel.userProfile)
    }
}
