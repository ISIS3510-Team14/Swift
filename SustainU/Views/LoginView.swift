import SwiftUI
import Auth0

struct LoginView: View {
    @Binding var isAuthenticated: Bool
    @Binding var userProfile: Profile
    
    var body: some View {
        VStack {
            Spacer()
            // Mostrar la imagen al inicio de la vista
            Image("peopleCartoonLogo")  // Usa el nombre que diste a la imagen en Assets
                .resizable()  // Para que sea escalable
                .scaledToFit()  // Para que mantenga su relación de aspecto
                .frame(width: 300, height: 300)  // Ajusta el tamaño según lo necesites
            
            // Mostrar la imagen al inicio de la vista
            Image("logoBigger")  // Usa el nombre que diste a la imagen en Assets
                .resizable()  // Para que sea escalable
                .scaledToFit()  // Para que mantenga su relación de aspecto
                .frame(width: 200, height: 200)  // Ajusta el tamaño según lo necesites
                .padding(.bottom, 40)  // Añadir espacio debajo de la imagen
            
            Text("SustainU")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.black)
                .padding(.bottom, 40)
            
            // Unificar botones de Sign In y Sign Up
            Button(action: {
                authenticate()
            }) {
                Text("Log in / Sign up")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .frame(width: 220, height: 60)
                    .background(Color.green)
                    .cornerRadius(15.0)
            }
            .padding(.bottom, 20)

            Spacer()
            
        }
    }
    
    // Función de autenticación (tanto para iniciar sesión como registrarse)
    func authenticate() {
        Auth0
            .webAuth()
            .start { result in
                switch result {
                case .failure(let error):
                    print("Failed with: \(error)")
                case .success(let credentials):
                    self.isAuthenticated = true
                    self.userProfile = Profile.from(credentials.idToken)
                    print("User profile: \(self.userProfile)")
                }
            }
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView(isAuthenticated: .constant(false), userProfile: .constant(Profile.empty))
    }
}
