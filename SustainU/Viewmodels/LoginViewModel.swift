//
//  LoginViewModel.swift
//  SustainU
//
//  Created by Duarte Mantilla Ernesto Jose on 29/10/24.
//

import SwiftUI
import Auth0
import Combine

class LoginViewModel: ObservableObject {

    static let shared = LoginViewModel()
    private var cancellables = Set<AnyCancellable>()

    @Published var isAuthenticated: Bool = false
    @Published var userProfile: UserProfile = .empty
    @Published var isConnected: Bool = false
    @Published var showBackOnlineMessage: Bool = false
    @Published var showNoSessionAlert: Bool = false

    let connectivityManager = ConnectivityManager.shared
    var hasSavedSession: Bool {
        let tokenExists = KeychainService.loadToken() != nil
        print("Has saved session: \(tokenExists)")
        return tokenExists
    }

    private init() {
        loadSession() // Load session on initialization

        connectivityManager.$isConnected
            .receive(on: RunLoop.main)
            .sink { isConnected in
                self.isConnected = isConnected
                if isConnected {
                    self.showBackOnlineMessage = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        self.showBackOnlineMessage = false
                    }
                    self.refreshUserProfile()
                }
            }
            .store(in: &cancellables)
    }

    func authenticate() {
        if isConnected {
            // Proceed with Auth0 authentication
            Auth0
                .webAuth()
                .start { result in
                    switch result {
                    case .failure(let error):
                        print("Failed with: \(error)")
                    case .success(let credentials):
                        self.isAuthenticated = true
                        self.userProfile = UserProfile.from(credentials.idToken)
                        print("User profile: \(self.userProfile)")
                        self.saveSession(credentials.idToken)
                    }
                }
        } else {
            // Attempt offline login
            if let token = KeychainService.loadToken() {
                self.isAuthenticated = true
                self.userProfile = KeychainService.loadProfile() ?? .empty
                print("Offline login successful")
            } else {
                print("No saved session. Cannot login offline.")
                self.showNoSessionAlert = true // Trigger an alert
            }
        }
    }

    func logout() {
        if isConnected {
            // Online logout via Auth0
            Auth0
                .webAuth()
                .clearSession(federated: false) { result in
                    switch result {
                    case .success:
                        self.clearLocalSession()
                        print("User logged out")
                    case .failure(let error):
                        print("Failed with: \(error)")
                    }
                }
        } else {
            // Offline logout
            clearLocalSession()
            print("Logged out locally without internet connection")
        }
    }

    private func saveSession(_ idToken: String) {
        KeychainService.saveToken(idToken)
        KeychainService.saveProfile(self.userProfile)
    }

    func loadSession() {
        if let token = KeychainService.loadToken(),
           let profile = KeychainService.loadProfile() {
            self.isAuthenticated = true
            self.userProfile = profile
            print("Session loaded successfully")
        } else {
            print("No saved session found")
        }
    }

    func clearLocalSession() {
        //KeychainService.deleteToken()
        //KeychainService.deleteProfile()
        self.isAuthenticated = false
        self.userProfile = .empty
    }

    func refreshUserProfile() {
        guard isAuthenticated else { return }
        guard let token = KeychainService.loadToken() else { return }

        Auth0
            .users(token: token)
            .get("me")
            .start { result in
                switch result {
                case .success(let profileInfo):
                    // Update profile with fresh data
                    self.userProfile = UserProfile.from(profileInfo)
                    self.saveSession(token)
                case .failure(let error):
                    print("Failed to refresh profile: \(error)")
                }
            }
    }
}
