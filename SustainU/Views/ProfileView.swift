import SwiftUI
import Auth0

struct ProfileView: View {
    
    var userProfile: Profile

    
    @ObservedObject private var viewModel = LoginViewModel.shared  // Usamos el LoginViewModel para acceder al perfil
    @Binding var isAuthenticated: Bool
    @Environment(\.presentationMode) var presentationMode  // Para cerrar la vista actual

    var body: some View {
        VStack {
            // Botón de regreso en la esquina superior izquierda
            HStack {
                Button(action: {
                    // Acción para regresar al HomeView
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Image(systemName: "arrow.backward")  // Ícono de la flecha de salida
                        .font(.title)
                        .foregroundColor(Color.green)  // Color de la flecha
                }
                Spacer()
            }
            .padding(.leading, 20)
            .padding(.top, 10)

            // Imagen circular con inicial del nombre o imagen de perfil
            Spacer()
                .frame(height: 40)  // Espacio superior adicional

            if let url = URL(string: viewModel.userProfile.picture), NetworkMonitor.shared.isConnected {
                // Muestra la imagen si hay conexión
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
                // Muestra la inicial si no hay conexión o no se encuentra la imagen
                Circle()
                    .fill(Color.red)
                    .frame(width: 120, height: 120)
                    .overlay(Text(viewModel.userProfile.name.prefix(1))
                                .font(.largeTitle)
                                .foregroundColor(.white))
                    .padding()
            }

            Spacer()
                .frame(height: 20)  // Espacio entre la imagen y los datos del usuario

            // Nickname del usuario
            Text(viewModel.userProfile.nickname)
                .font(.title2)
                .fontWeight(.bold)
                .padding(.top)

            // Email del usuario
            Text("Email: \(viewModel.userProfile.email)")
                .font(.subheadline)
                .foregroundColor(.gray)
                .padding(.top, 2)

            Spacer()

            // Botón de cierre de sesión
            Button(action: {
                logout()
            }) {
                HStack {
                    Image(systemName: "arrow.right.square.fill")
                        .font(.title2)
                    Text("Logout")
                        .font(.headline)
                        .fontWeight(.bold)
                        .background(Color("redLogoColor"))
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
        if NetworkMonitor.shared.isConnected {
            // Logout en línea a través de Auth0
            Auth0
                .webAuth()
                .clearSession(federated: false) { result in
                    switch result {
                    case .success:
                        self.viewModel.clearLocalSession()
                        self.isAuthenticated = false
                        print("User logged out")
                    case .failure(let error):
                        print("Failed with: \(error)")
                    }
                }
        } else {
            // Logout sin conexión
            viewModel.clearLocalSession()
            self.isAuthenticated = false
            print("Logged out locally without internet connection")
        }
    }
}


struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView(userProfile: Profile.empty, isAuthenticated: .constant(true))
    }
}
