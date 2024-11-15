import SwiftUI
import Auth0
import Network
import FirebaseFirestore

struct HomeView: View {
    // MARK: - Properties
    var userProfile: UserProfile
    @ObservedObject private var viewModel = LoginViewModel.shared
    @State private var selectedTab: Int = 0
    @State private var isShowingCameraView = false
    @StateObject private var collectionPointViewModel = CollectionPointViewModel()
    @State private var isShowingProfile = false
    @State private var showOfflinePopup = false
    @State private var hasTemporaryImages: Bool = false
    @State private var showSavedImagesSheet = false
    @State private var selectedImage: UIImage?
    @ObservedObject private var connectivityManager = ConnectivityManager.shared
    
    // MARK: - Body
    var body: some View {
        ZStack {
            Color.white.edgesIgnoringSafeArea(.all)
            
            TabView(selection: $selectedTab) {
                // Home Tab
                NavigationView {
                    ScrollView {
                        VStack {
                            // Using TopBarView with correct parameters
                            TopBarView(
                                profilePictureURL: viewModel.userProfile.picture,
                                connectivityManager: connectivityManager,
                                onProfileTap: {
                                    isShowingProfile = true
                                }
                            )
                            
                            // Rest of the view remains the same...
                            let firstName = viewModel.userProfile.name.components(separatedBy: " ").first ?? viewModel.userProfile.name
                            Text("Hi, \(firstName)")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .padding(.top, 10)
                            
                            // Record section
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
                            
                            // Grid options
                            VStack(spacing: 20) {
                                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 20) {
                                    // Map Button
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
                                    
                                    // Scoreboard Button
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
                                    
                                    // Recycle Button
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
                                    
                                    // History Button
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
                            
                            // Scan button
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
                            
                            // Temporary images button
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
                        checkForTemporaryImages()
                    }
                }
                
                // Map Tab
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
                    if !collectionPointViewModel.isNavigatingFromMainMenu {
                        collectionPointViewModel.incrementMapFromNavBar()
                    }
                    collectionPointViewModel.isNavigatingFromMainMenu = false
                }
                
                // Camera Tab
                CameraView(profilePictureURL: viewModel.userProfile.picture,
                          selectedTab: $selectedTab,
                          selectedImage: $selectedImage)
                    .tabItem {
                        Image("logoCamera")
                            .renderingMode(.template)
                        Text("Camera")
                    }
                    .tag(2)
                
                // Recycle Tab
                NavigationView {
                    RecycleView(userProfile: viewModel.userProfile)
                }
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
            .onChange(of: selectedTab) { newTab in
                if newTab == 2 {
                    logClickCounter(field: "scan")
                } else if newTab == 3 {
                    logClickCounter(field: "info")
                }
            }
        }
        // Sheets
        .sheet(isPresented: $isShowingProfile) {
            ProfileView(userProfile: viewModel.userProfile)
        }
        .sheet(isPresented: $showSavedImagesSheet) {
            SavedImagesView(selectedImage: $selectedImage, selectedTab: $selectedTab)
        }
    }
    
    // MARK: - Helper Methods
    private func checkInternetAndNavigateToMap() {
        let monitor = NWPathMonitor()
        let queue = DispatchQueue(label: "InternetCheck")
        
        monitor.pathUpdateHandler = { path in
            DispatchQueue.main.async {
                if path.status != .satisfied {
                    showOfflinePopup = true
                } else {
                    collectionPointViewModel.isNavigatingFromMainMenu = true
                    collectionPointViewModel.incrementMapFromMainMenu()
                    selectedTab = 1
                }
                monitor.cancel()
            }
        }
        
        monitor.start(queue: queue)
    }
    
    private func checkForTemporaryImages() {
        let savedImages = CameraViewmodel().loadSavedImages()
        hasTemporaryImages = !savedImages.isEmpty
    }
    
    private func logClickCounter(field: String) {
        let db = Firestore.firestore()
        let docRef = db.collection("scan_info").document("counters")
        
        docRef.updateData([field: FieldValue.increment(Int64(1))]) { error in
            if let error = error {
                print("Error updating document: \(error)")
            } else {
                print("Document successfully updated")
            }
        }
    }
}
