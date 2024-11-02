//
//  ProfileView.swift
//  SustainU
//
//  Created by Duarte Mantilla Ernesto Jose on 29/10/24.
//

import SwiftUI
import Auth0

struct ProfileView: View {
    var userProfile: UserProfile

    @ObservedObject private var viewModel = LoginViewModel.shared
    //@Binding var isAuthenticated: Bool
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        VStack {
            // Back button in the top-left corner
            HStack {
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Image(systemName: "arrow.backward")
                        .font(.title)
                        .foregroundColor(Color.green)
                }
                Spacer()
            }
            .padding(.leading, 20)
            .padding(.top, 10)

            Spacer()
                .frame(height: 40)

            if let url = URL(string: viewModel.userProfile.picture), ConnectivityManager.shared.isConnected {
                // Show the image if connected
                AsyncImage(url: url) { image in
                    image
                        .resizable()
                        .scaledToFit()
                        .frame(width: 120, height: 120)
                        .clipShape(Circle())
                        .padding()
                } placeholder: {
                    Circle()
                        .fill(Color.red)
                        .frame(width: 120, height: 120)
                        .overlay(Text(viewModel.userProfile.name.prefix(1))
                                    .font(.largeTitle)
                                    .foregroundColor(.white))
                        .padding()
                }
            } else {
                // Show initials if not connected
                Circle()
                    .fill(Color.red)
                    .frame(width: 120, height: 120)
                    .overlay(Text(viewModel.userProfile.name.prefix(1))
                                .font(.largeTitle)
                                .foregroundColor(.white))
                    .padding()
            }

            Spacer()
                .frame(height: 20)

            // User's nickname
            Text(viewModel.userProfile.nickname)
                .font(.title2)
                .fontWeight(.bold)
                .padding(.top)

            // User's email
            Text("Email: \(viewModel.userProfile.email)")
                .font(.subheadline)
                .foregroundColor(.gray)
                .padding(.top, 2)

            Spacer()

            // Logout button
            Button(action: {
                logout()
            }) {
                HStack {
                    Image(systemName: "arrow.right.square.fill")
                        .font(.title2)
                    Text("Logout")
                        .font(.headline)
                        .fontWeight(.bold)
                }
                .foregroundColor(.white)
                .padding()
                .frame(width: 220, height: 50)
                .background(Color.red)
                .cornerRadius(25)
            }
            .padding(.bottom, 40)
        }
        .padding()
        .background(Color.white)
    }

    func logout() {
            if ConnectivityManager.shared.isConnected {
                // Online logout via Auth0
                Auth0
                    .webAuth()
                    .clearSession(federated: false) { result in
                        switch result {
                        case .success:
                            DispatchQueue.main.async {
                                self.viewModel.clearLocalSession()
                                self.presentationMode.wrappedValue.dismiss()
                            }
                            print("User logged out")
                        case .failure(let error):
                            print("Failed with: \(error)")
                        }
                    }
            } else {
                // Offline logout
                viewModel.clearLocalSession()
                DispatchQueue.main.async {
                    self.presentationMode.wrappedValue.dismiss()
                }
                print("Logged out locally without internet connection")
            }
    }

}


