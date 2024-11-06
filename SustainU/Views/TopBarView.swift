import SwiftUI

struct TopBarView: View {
    var profilePictureURL: String
    @ObservedObject var connectivityManager: ConnectivityManager
    var onProfileTap: () -> Void = {}
    
    var body: some View {
        HStack {
            // Logo SU
            Image("logoBigger")
                .resizable()
                .scaledToFit()
                .frame(width: 50, height: 50)
            
            Spacer()
            
            // Mostrar el mensaje "No internet connection" si no hay conexión
            if !connectivityManager.isConnected {
                Text("No internet connection")
                    .font(.caption)
                    .foregroundColor(.red)
                    .transition(.opacity) // Efecto de transición suave
                    .padding(.trailing, 5)
            }

            // Indicador de conexión (icono de nube)
            Image(connectivityManager.isConnected ? "cloudConnected" : "cloudDisconnected")
                .resizable()
                .frame(width: 20, height: 20)
                .padding(.trailing, 5)
                .onChange(of: connectivityManager.isConnected) {
                    print("TopBarView: isConnected status changed.")
                }

            // Botón de foto de perfil
            Button(action: {
                onProfileTap()
            }) {
                if connectivityManager.isConnected, let url = URL(string: profilePictureURL) {
                    AsyncImage(url: url) { image in
                        image
                            .resizable()
                            .frame(width: 40, height: 40)
                            .clipShape(Circle())
                    } placeholder: {
                        Image(systemName: "person.circle.fill")
                            .resizable()
                            .frame(width: 40, height: 40)
                            .clipShape(Circle())
                    }
                } else {
                    // Muestra iniciales o placeholder cuando está offline
                    Circle()
                        .fill(Color.gray)
                        .frame(width: 40, height: 40)
                        .overlay(Text(getInitials(from: profilePictureURL))
                                    .font(.headline)
                                    .foregroundColor(.white))
                }
            }
        }
        .padding()
        .background(Color.white.opacity(0.99))
    }

    // Helper function para obtener las iniciales
    func getInitials(from name: String) -> String {
        let nameComponents = name.components(separatedBy: " ")
        let initials = nameComponents.compactMap { $0.first }.prefix(2)
        return initials.map { String($0) }.joined()
    }
}

struct TopBarView_Previews: PreviewProvider {
    static var previews: some View {
        TopBarView(profilePictureURL: "https://example.com/profile_picture.jpg", connectivityManager: ConnectivityManager.shared) {
            // Acción de vista previa
        }
    }
}
