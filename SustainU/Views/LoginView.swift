import SwiftUI

struct LoginView: View {
    @ObservedObject var viewModel: LoginViewModel
    
    var body: some View {
        VStack {
            Spacer()
            
            // Logo y título
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
            
            // Aviso en rojo cuando no hay conexión
            if !viewModel.isConnected {
                Text("No internet connection")
                    .foregroundColor(.red)
                    .font(.headline)
                    .padding(.bottom, 10)
            }
            
            // Botón de inicio de sesión
            Button(action: {
                viewModel.authenticate()
            }) {
                Text("Log in / Sign up")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .frame(width: 220, height: 60)
                    .background(viewModel.isConnected ? Color("greenLogoColor") : Color.gray)
                    .cornerRadius(15.0)
            }
            .disabled(!viewModel.isConnected) // Desactivar el botón si no hay conexión
            .padding(.bottom, 20)
            
            // Botón de Retry si no hay conexión
            if !viewModel.isConnected {
                Button(action: {
                    viewModel.authenticate() // Reintenta la autenticación
                }) {
                    Text("Retry")
                        .foregroundColor(.blue)
                }
                .padding(.top, 10)
            }
            
            Spacer()
        }
        .onAppear {
            viewModel.loadSession() // Cargar la sesión al aparecer
        }
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView(viewModel: LoginViewModel.shared)
    }
}
