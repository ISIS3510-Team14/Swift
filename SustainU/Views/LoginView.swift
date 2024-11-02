//
//  LoginView.swift
//  SustainU
//
//  Created by Duarte Mantilla Ernesto Jose on 29/10/24.
//

import SwiftUI

struct LoginView: View {
    @ObservedObject var viewModel: LoginViewModel
    @State private var showInstructions = false
    @State private var refreshView = false

    //@State private var showHomeView = false

    var body: some View {
        VStack {
            Spacer()
            
            Image("peopleCartoonLogo")
                .resizable()
                .scaledToFit()
                .frame(width: 300, height: 300)
            
            Image("logoBigger")
                .resizable()
                .scaledToFit()
                .frame(width: 200, height: 200)
                .padding(.bottom, 40)
            
            Text("SustainU")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.black)
                .padding(.bottom, 40)
            
            // Login Button
            Button(action: {
                viewModel.authenticate()
            }) {
                Text("Log in / Sign up")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .frame(width: 220, height: 60)
                    .background(Color("greenLogoColor"))
                    .cornerRadius(15.0)
            }
            .disabled(!viewModel.isConnected && !viewModel.hasSavedSession)
            // Disable button only if there's no internet and no saved session
            
            // "Login Instructions" link
            Button(action: {
                showInstructions = true
            }) {
                Text("Login Instructions")
                    .font(.subheadline)
                    .foregroundColor(.blue)
                    .underline()
            }
            .padding(.top, 10)
            .sheet(isPresented: $showInstructions) {
                LoginInstructionsView()
            }
            
            // Show "No internet connection" message if not connected
            if !viewModel.isConnected {
                Text("No internet connection")
                    .foregroundColor(.red)
                    .padding(.top, 10)
            }
            
            Spacer()
        }
        .onReceive(viewModel.$isConnected) { isConnected in
                    print("LoginView: isConnected = \(isConnected)")
                    self.refreshView.toggle()
                }
        .id(refreshView)
        
        .alert(isPresented: $viewModel.showNoSessionAlert) {
            Alert(
                title: Text("No Saved Session"),
                message: Text("You need an internet connection to log in for the first time."),
                dismissButton: .default(Text("OK"))
            )
        }
        .overlay(
            Group {
                if viewModel.showBackOnlineMessage {
                    Text("Back online")
                        .font(.subheadline)
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.green)
                        .cornerRadius(8)
                        .transition(.opacity)
                        .animation(.easeInOut, value: viewModel.showBackOnlineMessage)
                        .onAppear {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                viewModel.showBackOnlineMessage = false
                            }
                        }
                        .padding(.top, 20)
                }
            },
            alignment: .top
        )
    }
}
