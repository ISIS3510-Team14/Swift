import SwiftUI
import Auth0

struct HomeView: View {
    var userProfile: Profile
    @Binding var isAuthenticated: Bool
    
    @State private var selectedTab: Int = 0
    @State private var isShowingCameraView = false

    var body: some View {
        ZStack {
            // White background that extends to all edges
            Color.white.edgesIgnoringSafeArea(.all)
            
            TabView(selection: $selectedTab) {
                // Home Tab
                NavigationView {
                    ScrollView {
                        VStack {
                            // Reusing the TopBarView and passing the user profile picture
                            TopBarView(profilePictureURL: userProfile.picture)
                            
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
                                    Button(action: {
                                        selectedTab = 1 // Switch to Map tab
                                    }) {
                                        VStack {
                                            Image("logoMap")
                                                .resizable()
                                                .renderingMode(.template)
                                                .frame(width: 40, height: 40)
                                                .scaledToFit()
                                            Text("See green points")
                                                .font(.headline)
                                                .foregroundColor(.black)
                                        }
                                    }

                                    Button(action: {
                                        selectedTab = 4 // Switch to Scoreboard tab
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
                                        selectedTab = 3 // Switch to Recycle tab
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
                                        // Action for History
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
                                selectedTab = 2 // Switch to Camera tab
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

                // Map Tab
                
                ExpandableSearchView(profilePictureURL: userProfile.picture)
                    .tabItem {
                        Image("logoMap")
                            .renderingMode(.template)
                        Text("Map")
                    }
                    .tag(1)

                // Camera Tab
                CameraView(profilePictureURL: userProfile.picture)
                    .tabItem {
                        Image("logoCamera")
                            .renderingMode(.template)
                        Text("Camera")
                    }
                    .tag(2)

                // Recycle Tab
                Text("Recycle View")
                    .tabItem {
                        Image("logoRecycle")
                            .renderingMode(.template)
                        Text("Recycle")
                    }
                    .tag(3)

                // Scoreboard Tab
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
        }
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

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView(userProfile: Profile.empty, isAuthenticated: .constant(true))
    }
}
