import SwiftUI
import Auth0

struct ProfileView: View {
    var userProfile: Profile
    @Binding var isAuthenticated: Bool
    @Environment(\.presentationMode) var presentationMode  // Para poder cerrar la vista actual

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

            // Imagen circular con inicial del nombre o imagen de perfil, arriba
            Spacer()
                .frame(height: 40)  // Espacio superior adicional
            
            if let url = URL(string: userProfile.picture) {
                AsyncImage(url: url) { image in
                    image
                        .resizable()
                        .scaledToFit()
                        .frame(width: 120, height: 120)
                        .clipShape(Circle())
                        .padding()
                } placeholder: {
                    Circle()
                        .fill(Color.red)  // Color de fondo similar al del prototipo
                        .frame(width: 120, height: 120)
                        .overlay(Text(userProfile.name.prefix(1))
                                    .font(.largeTitle)
                                    .foregroundColor(.white))
                        .padding()
                }
            }

            Spacer()
                .frame(height: 20)  // Espacio entre la imagen y los datos del usuario

            // Nickname del usuario en vez de "Name"
            Text((userProfile.nickname))
                .font(.title2)
                .fontWeight(.bold)
                .padding(.top)

            // Email del usuario
            Text("Email: \(userProfile.email)")
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
                .cornerRadius(25)  // Bordes más redondeados, similar al estilo del botón del prototipo
            }
            .padding(.bottom, 40)
        }
        .padding()
        .background(Color.white)
    }

    func logout() {
        Auth0
            .webAuth()
            .clearSession(federated: false) { result in
                switch result {
                case .success:
                    self.isAuthenticated = false
                    print("User logged out")
                case .failure(let error):
                    print("Failed with: \(error)")
                }
            }
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView(userProfile: Profile.empty, isAuthenticated: .constant(true))
    }
}
