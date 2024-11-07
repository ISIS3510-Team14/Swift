import SwiftUI
import Auth0
import Network

struct HomeView: View {
    var userProfile: UserProfile
    @ObservedObject private var viewModel = LoginViewModel.shared
    @State private var selectedTab: Int = 0
    @State private var isShowingCameraView = false
    @StateObject private var collectionPointViewModel = CollectionPointViewModel()
    @State private var isShowingProfile = false
    @State private var showOfflinePopup = false
    
    var body: some View {
        ZStack {
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
                                Button(action: {
                                    isShowingProfile = true
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
                                    // Botón del mapa modificado para verificar conexión
                                    Button(action: {
                                        checkInternetAndNavigateToMap()
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
                                        selectedTab = 4
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
                                        selectedTab = 3
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
                                selectedTab = 2
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

                // Map Tab con overlay para el popup
                ZStack {
                    ExpandableSearchView(collectionPointViewModel: collectionPointViewModel,
                                       profilePictureURL: viewModel.userProfile.picture)
                    
                    if showOfflinePopup {
                        Color.black.opacity(0.4)
                            .edgesIgnoringSafeArea(.all)
                            .onTapGesture {
                                showOfflinePopup = false
                            }
                        
                        OfflineMapPopupView(isPresented: $showOfflinePopup)
                    }
                }
                .tabItem {
                    Image("logoMap")
                        .renderingMode(.template)
                    Text("Map")
                }
                .tag(1)
                .onAppear {
                    collectionPointViewModel.incrementMapCount()
                }

                CameraView(profilePictureURL: viewModel.userProfile.picture)
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
        }
    }
    
    private func checkInternetAndNavigateToMap() {
        let monitor = NWPathMonitor()
        let queue = DispatchQueue(label: "InternetCheck")
        
        monitor.pathUpdateHandler = { path in
            DispatchQueue.main.async {
                if path.status != .satisfied {
                    showOfflinePopup = true
                } else {
                    selectedTab = 1
                }
                monitor.cancel()
            }
        }
        
        monitor.start(queue: queue)
    }
}
