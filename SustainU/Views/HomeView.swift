import SwiftUI
import Auth0

struct HomeView: View {
    
    var userProfile: UserProfile
    
    @ObservedObject private var viewModel = LoginViewModel.shared
    //@Binding var isAuthenticated: Bool
    @StateObject private var connectivityManager = ConnectivityManager.shared

    @State private var selectedTab: Int = 0
    @State private var isShowingCameraView = false
    @StateObject private var collectionPointViewModel = CollectionPointViewModel()
    @State private var isShowingProfile = false  // Estado para mostrar la vista de perfil
    
    @State private var showPopup = false // Estado para mostrar el popup
    @State private var showSavedImagesSheet = false // Estado para mostrar el sheet de imágenes
    @State private var selectedImage: UIImage? = nil // Añade selectedImage para compartir entre vistas
    @State private var hasTemporaryImages = false // Estado para controlar la visibilidad del botón

    var body: some View {
        ZStack {
            // Fondo blanco que se extiende a todos los bordes
            Color.white.edgesIgnoringSafeArea(.all)
            
            TabView(selection: $selectedTab) {
                // Home Tab
                NavigationView {
                    ScrollView {
                        VStack {
                            // Logo e imagen de perfil
                            HStack {
                                Image("logoBigger")
                                    .resizable()
                                    .frame(width: 50, height: 50)
                                Spacer()
                                // Botón que muestra la vista de perfil
                                Button(action: {
                                    isShowingProfile = true  // Muestra la vista de perfil
                                }) {
                                    AsyncImage(url: URL(string: viewModel.userProfile.picture)) { image in
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
                            }
                            .padding(.horizontal)
                            .padding(.top, 20)
                            
                            // Saludo al usuario con solo el primer nombre
                            let firstName = viewModel.userProfile.name.components(separatedBy: " ").first ?? viewModel.userProfile.name
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
                                    VStack(alignment: .leading) {
                                        Text("68 Points")
                                            .font(.title)
                                            .fontWeight(.bold)

                                        Text("99 Days")
                                            .font(.subheadline)
                                            .foregroundColor(Color("blueLogoColor"))
                                    }
                                    Spacer()
                                }
                            }
                            .padding()
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(15)
                            .padding(.horizontal)

                            // Grid con las opciones
                            VStack(spacing: 20) {
                                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 20) {
                                    // Botones sin bordes ni fondos grises
                                    Button(action: {
                                        selectedTab = 1 // Cambiar a la pestaña del Mapa
                                    }) {
                                        VStack {
                                            Image("logoMap")
                                                .resizable()
                                                .renderingMode(.template)
                                                .frame(width: 40, height: 40)
                                            Text("See green points")
                                                .font(.headline)
                                                .foregroundColor(.black)
                                        }
                                    }

                                    Button(action: {
                                        selectedTab = 4 // Cambiar a la pestaña de Scoreboard
                                    }) {
                                        VStack {
                                            Image("logoScoreboard")
                                                .resizable()
                                                .renderingMode(.template)
                                                .frame(width: 40, height: 40)
                                            Text("See Scoreboard")
                                                .font(.headline)
                                                .foregroundColor(.black)
                                        }
                                    }

                                    Button(action: {
                                        selectedTab = 3 // Cambiar a la pestaña de Recycle
                                    }) {
                                        VStack {
                                            Image("logoRecycle")
                                                .resizable()
                                                .renderingMode(.template)
                                                .frame(width: 40, height: 40)
                                            Text("What can I recycle?")
                                                .font(.headline)
                                                .foregroundColor(.black)
                                        }
                                    }

                                    Button(action: {
                                        // Acción para History
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

                            Text("Start recycling!")
                                .font(.title2)
                                .fontWeight(.bold)
                                .padding(.bottom, 10)

                            Button(action: {
                                selectedTab = 2 // Cambiar a la pestaña de Camera
                            }) {
                                Text("Scan")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .padding()
                                    .frame(width: 220, height: 60)
                                    .background(Color("greenLogoColor"))
                                    .cornerRadius(15)
                            }
                            .padding(.bottom, 40)
                            
                            
                            // Botón para ver imágenes temporales, solo si hay imágenes guardadas
                            if hasTemporaryImages && connectivityManager.isConnected {
                                Button(action: {
                                    showSavedImagesSheet = true
                                }) {
                                    Text("View temporary images")
                                        .font(.headline)
                                        .foregroundColor(.white)
                                        .padding()
                                        .frame(maxWidth: .infinity)
                                        .background(Color("greenLogoColor"))
                                        .cornerRadius(15)
                                        .frame(width: 320, height: 60)
                                }
                            }
                        }
                    }
                    .navigationBarHidden(true)
                }
                .tabItem {
                    Image("logoHome")
                        .renderingMode(.template)
                    Text("Home")
                }
                .tag(0)
                .onAppear {
                    if connectivityManager.isConnected {
                        checkForTemporaryImages() // Verificar si hay imágenes temporales al cargar la vista
                    }
                }


                // Map Tab
                ExpandableSearchView(collectionPointViewModel: collectionPointViewModel, profilePictureURL: viewModel.userProfile.picture)
                    .tabItem {
                        Image("logoMap")
                            .renderingMode(.template)
                        Text("Map")
                    }
                    .tag(1)
                    .onAppear {
                        collectionPointViewModel.incrementMapCount()
                    }

                CameraView(profilePictureURL: viewModel.userProfile.picture, selectedTab: $selectedTab, selectedImage: $selectedImage)  
                    .tabItem {
                        Image("logoCamera")
                            .renderingMode(.template)
                        Text("Camera")
                    }
                    .tag(2)

                Text("Recycle View")
                    .tabItem {
                        Image("logoRecycle")
                            .renderingMode(.template)
                        Text("Recycle")
                    }
                    .tag(3)

                Text("Scoreboard View")
                    .tabItem {
                        Image("logoScoreboard")
                            .renderingMode(.template)
                        Text("Scoreboard")
                    }
                    .tag(4)
            }
            .accentColor(Color("greenLogoColor"))
            .onAppear {
                UITabBar.appearance().backgroundColor = .white
                UITabBar.appearance().unselectedItemTintColor = .gray
            }
        
            
            // Presentación de la vista de perfil como un modal
            .sheet(isPresented: $isShowingProfile) {
                ProfileView(userProfile: viewModel.userProfile)
            }
            // Observe authentication state
            
            // Sheet para mostrar las imágenes guardadas
            .sheet(isPresented: $showSavedImagesSheet) {
                SavedImagesView(selectedImage: $selectedImage, selectedTab: $selectedTab)
            }

        }
    }
    
    // Función para verificar si hay imágenes temporales guardadas
    private func checkForTemporaryImages() {
        print("chequeando imagenes emporales")
        let savedImages = CameraViewmodel().loadSavedImages()
        hasTemporaryImages = !savedImages.isEmpty
    }
}
