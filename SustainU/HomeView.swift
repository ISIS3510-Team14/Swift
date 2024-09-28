import SwiftUI
import Auth0

struct HomeView: View {
    var userProfile: Profile
    @Binding var isAuthenticated: Bool
    
    @State private var selectedTab: Int = 0  // Estado que controla la pestaña seleccionada
    @State private var isShowingCameraView = false  // Estado para mostrar CameraView

    var body: some View {
        TabView {
            // Home Tab
            NavigationView {
                VStack {
                    // Logo e imagen de perfil
                    HStack {
                        Image("logoBigger") // Logo personalizado
                            .resizable()
                            .frame(width: 50, height: 50)
                        Spacer()
                        AsyncImage(url: URL(string: userProfile.picture)) { image in
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
                    }
                    .padding(.horizontal)
                    .padding(.top, 20)
                    
                    // Saludo al usuario con solo el primer nombre
                    let firstName = userProfile.name.components(separatedBy: " ").first ?? userProfile.name
                    Text("Hi, \(firstName)")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .padding(.top, 10)
                    
                    // Sección de puntos y días
                    VStack(alignment: .leading) {
                        Text("Your record")
                            .font(.headline)
                            .padding(.bottom, 2)

                        HStack {
                            VStack(alignment: .leading) {  // Aseguramos la alineación a la izquierda
                                Text("68 Points")
                                    .font(.title)
                                    .fontWeight(.bold)

                                Text("99 Days")
                                    .font(.subheadline)
                                    .foregroundColor(Color("blueLogoColor"))  // Usamos el color azul de los assets
                            }
                            Spacer()  // Para que el VStack quede a la izquierda y el espacio esté a la derecha
                        }
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(15)
                    .padding(.horizontal)

                    // Grid con las opciones
                    VStack(spacing: 20) {
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 20) {
                            Button(action: {
                                // Acción de ver puntos verdes
                            }) {
                                VStack {
                                    Image("logoMap") // Logo personalizado de Map
                                        .resizable()
                                        .renderingMode(.template)  // Habilitar cambio de color
                                        .frame(width: 40, height: 40)
                                    Text("See green points")
                                        .font(.headline)
                                        .foregroundColor(.black)
                                }
                            }

                            Button(action: {
                                // Acción de ver el scoreboard
                            }) {
                                VStack {
                                    Image("logoScoreboard") // Logo personalizado de Scoreboard
                                        .resizable()
                                        .renderingMode(.template)  // Habilitar cambio de color
                                        .frame(width: 40, height: 40)
                                    Text("See Scoreboard")
                                        .font(.headline)
                                        .foregroundColor(.black)
                                }
                            }

                            Button(action: {
                                // Acción de qué se puede reciclar
                            }) {
                                VStack {
                                    Image("logoRecycle") // Logo personalizado de Recycle
                                        .resizable()
                                        .renderingMode(.template)  // Habilitar cambio de color
                                        .frame(width: 40, height: 40)
                                    Text("What can I recycle?")
                                        .font(.headline)
                                        .foregroundColor(.black)
                                }
                            }

                            Button(action: {
                                selectedTab = 2  // Cambiamos a la pestaña de Camera (índice 2)
                            }) {
                                VStack {
                                    Image(systemName: "calendar")
                                        .resizable()
                                        .frame(width: 40, height: 40)
                                    Text("History")
                                        .font(.headline)
                                        .foregroundColor(.black)
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                    .padding(.top, 20)

                    Spacer()

                    // Texto "Start recycling!"
                    Text("Start recycling!")
                        .font(.title2)
                        .fontWeight(.bold)
                        .padding(.bottom, 10)

                    // Botón de Scan en la parte inferior
                    Button(action: {
                        isShowingCameraView = true  // Activamos la cámara cuando se pulsa el botón
                    }) {
                        Text("Scan")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .frame(width: 220, height: 60)
                            .background(Color.green)
                            .cornerRadius(15)
                    }
                    .padding(.bottom, 10)
                    
                    // Botón de cierre de sesión
                    Button(action: {
                        logout()
                    }) {
                        Text("Log out")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .frame(width: 220, height: 60)
                            .background(Color.red)
                            .cornerRadius(15)
                    }
                    .padding(.bottom, 40)

                    Spacer()
                }
                .navigationBarHidden(true)
            }
            .tabItem {
                Image("logoHome") // Logo personalizado de Home
                    .renderingMode(.template)  // Habilitar cambio de color
                Text("Home")
            }
            .tag(0)  // Índice de la pestaña Home

            // Map Tab
            Text("Map View")
                .tabItem {
                    Image("logoMap") // Logo personalizado de Map
                        .renderingMode(.template)  // Habilitar cambio de color
                    Text("Map")
                }
                .tag(1)  // Índice de la pestaña Map

            // Camera Tab
            CameraView()  // La vista de la cámara ahora está asociada con esta pestaña
                .tabItem {
                    Image("logoCamera") // Logo personalizado de Camera
                        .renderingMode(.template)  // Habilitar cambio de color
                    Text("Camera")
                }
                .tag(2)  // Índice de la pestaña Camera

            // Recycle Tab
            Text("Recycle View")
                .tabItem {
                    Image("logoRecycle") // Logo personalizado de Recycle
                        .renderingMode(.template)  // Habilitar cambio de color
                    Text("Recycle")
                }
                .tag(3)  // Índice de la pestaña Recycle

            // Scoreboard Tab
            Text("Scoreboard View")
                .tabItem {
                    Image("logoScoreboard") // Logo personalizado de Scoreboard
                        .renderingMode(.template)  // Habilitar cambio de color
                    Text("Scoreboard")
                }
                .tag(4)  // Índice de la pestaña Scoreboard
        }
        .accentColor(Color("greenLogoColor"))  // Aquí se aplica el color de highlight verde cuando una pestaña es seleccionada
    }
    
    // Función de logout
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

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView(userProfile: Profile.empty, isAuthenticated: .constant(true))
    }
}
