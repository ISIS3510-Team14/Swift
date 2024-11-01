import SwiftUI

struct LoginView: View {
    @ObservedObject var viewModel: LoginViewModel
    @State private var showInstructions = false  // New state variable

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
            
            if viewModel.isConnected {
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
                
                // New "Login Instructions" link
                Button(action: {
                    showInstructions = true  // Show the instructions view when tapped
                }) {
                    Text("Login Instructions")
                        .font(.subheadline)
                        .foregroundColor(.blue)
                        .underline()
                }
                .padding(.top, 10)
                .sheet(isPresented: $showInstructions) {
                    LoginInstructionsView()  // Present the instructions view
                }
            } else {
                Text("No internet connection")
                    .foregroundColor(.red)
                    .padding(.bottom, 10)
                
                Button(action: {
                    viewModel.connectivityManager.checkConnection()
                }) {
                    Text("Retry connection")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(width: 220, height: 60)
                        .background(Color.red)
                        .cornerRadius(15.0)
                }
                .padding(.bottom, 20)
            }

            Spacer()
        }
        .onChange(of: viewModel.isConnected) { isConnected in
            if isConnected {
                viewModel.showBackOnlineMessage = true
            }
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
