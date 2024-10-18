import SwiftUI
import MapKit
import Combine

struct ExpandableSearchView: View {
    
    @StateObject private var locationManager = LocationManager()
    @State private var searchText = ""
    @State private var offset: CGFloat = 500 // Starts partially visible
    @GestureState private var draggingOffset: CGFloat = 0
    @State private var userTrackingMode: MKUserTrackingMode = .none
    @State private var selectedPoint: CollectionPoint?
    @State private var isNavigatingToDetail = false
    @State private var keyboardHeight: CGFloat = 0
    @FocusState private var isSearchFocused: Bool
    
    let profilePictureURL: String
    let maxHeight: CGFloat = UIScreen.main.bounds.height - 100
    let minHeight: CGFloat = 500
    
    let collectionPoints = [
        CollectionPoint(name: "El Bobo", location: "Between buildings C and B", materials: "Recyclables and Organic", latitude: 4.60148, longitude: -74.06450, imageName: "recycling_bins"),
        CollectionPoint(name: "Carlos Pacheco Devia", location: "3rd and 4th flo                    or near the elevators", materials: "Organic, cardboard, glass", latitude: 4.601836, longitude: -74.065348, imageName: "recycling_bins"),
        CollectionPoint(name: "Mario Laserna building", location: "6th floor, next to the elevators", materials: "Organic, plastic and cardboard", latitude: 4.602814, longitude: -74.064313, imageName: "recycling_bins"),
        CollectionPoint(name: "La Gata Golosa", location: "between restrooms and basketball court", materials: "Containers, organic and plastic", latitude: 4.603397, longitude: -74.066441, imageName: "recycling_bins")
    ]
    
    var filteredPoints: [CollectionPoint] {
        let filtered = searchText.isEmpty ? collectionPoints : collectionPoints.filter { point in
            point.name.lowercased().contains(searchText.lowercased())
        }
        
        guard let userLocation = locationManager.location?.coordinate else {
            return filtered
        }
        
        return filtered.sorted { point1, point2 in
            let location1 = CLLocation(latitude: point1.latitude, longitude: point1.longitude)
            let location2 = CLLocation(latitude: point2.latitude, longitude: point2.longitude)
            let userCLLocation = CLLocation(latitude: userLocation.latitude, longitude: userLocation.longitude)
            
            return location1.distance(from: userCLLocation) < location2.distance(from: userCLLocation)
        }
    }
    
    var body: some View {
        NavigationView {
            ZStack(alignment: .top) {
                MapView(locationManager: locationManager,
                        userTrackingMode: $userTrackingMode,
                        collectionPoints: collectionPoints,
                        onAnnotationTap: { point in
                            self.selectedPoint = point
                            self.isNavigatingToDetail = true
                        })
                    .edgesIgnoringSafeArea(.all)
                    .safeAreaInset(edge: .top) {
                        Color.clear.frame(height: 0)
                    }
                
                VStack(spacing: 0) {
                    Color.clear
                        .frame(height: (UIApplication.shared.connectedScenes.first as? UIWindowScene)?
                        .windows.first?.safeAreaInsets.top ?? 20)
                    
                    TopBarView(profilePictureURL: profilePictureURL)
                    
                    Spacer()
                    
                    VStack(spacing: 15) {
                        Capsule()
                            .fill(Color.secondary)
                            .frame(width: 60, height: 4)
                            .padding(.top, 8)
                        
                        Text("Find collection points near you")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        SearchBarView(searchText: $searchText, focused: $isSearchFocused)
                        
                        ScrollView {
                            LazyVStack(alignment: .leading, spacing: 20) {
                                ForEach(filteredPoints) { point in
                                    NavigationLink(destination: CollectionPointDetailView(point: point)) {
                                        HStack(alignment: .top, spacing: 10) {
                                            Image("custom-pin-image")
                                                .resizable()
                                                .scaledToFit()
                                                .frame(width: 25, height: 25)
                                            
                                            VStack(alignment: .leading, spacing: 2) {
                                                Text(point.name)
                                                    .font(.headline)
                                                    .foregroundColor(.primary)
                                                
                                                Text(point.location)
                                                    .font(.subheadline)
                                                    .foregroundColor(.gray)
                                                
                                                Text(point.materials)
                                                    .font(.subheadline)
                                                    .foregroundColor(Color("blueLogoColor"))
                                            }
                                        }
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                            }
                            .padding(.top)
                        }
                    }
                    .padding(.horizontal)
                    .frame(maxHeight: maxHeight)
                    .background(Color(.systemBackground))
                    .cornerRadius(15)
                    .offset(y: max(calculateOffset(), 0))
                    .gesture(dragGesture)
                }
                
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Button(action: {
                            locationManager.startUpdatingLocation()
                            userTrackingMode = .follow
                        }) {
                            Image(systemName: "location.fill")
                                .padding()
                                .background(Color.white)
                                .clipShape(Circle())
                                .shadow(radius: 4)
                        }
                        .padding()
                    }
                }
            }
            .edgesIgnoringSafeArea(.all)
            .onAppear {
                locationManager.startUpdatingLocation()
                setupKeyboardObservers()
            }
            .onDisappear {
                removeKeyboardObservers()
            }
            .background(
                                NavigationLink(
                                    destination: CollectionPointDetailView(
                                        point: selectedPoint ?? CollectionPoint(
                                            name: "",
                                            location: "",
                                            materials: "",
                                            latitude: 0,
                                            longitude: 0,
                                            imageName: "default-image" // Add a default image name here
                                        )
                                    ),
                                    isActive: $isNavigatingToDetail
                                ) {
                                    EmptyView()
                                }
                            )
        }
    }
    
    private func calculateOffset() -> CGFloat {
        if isSearchFocused {
            return min(self.offset + self.draggingOffset, keyboardHeight - maxHeight)
        } else {
            return self.offset + self.draggingOffset
        }
    }
    
    private var dragGesture: some Gesture {
        DragGesture()
            .updating($draggingOffset) { value, state, _ in
                state = value.translation.height
            }
            .onEnded { value in
                withAnimation(.spring()) {
                    let dragHeight = value.translation.height
                    let dragThreshold = self.maxHeight * 0.3
                    if dragHeight > dragThreshold {
                        self.offset = self.minHeight
                    } else if -dragHeight > dragThreshold {
                        self.offset = 0
                    } else if self.offset > self.minHeight / 2 {
                        self.offset = self.minHeight
                    } else {
                        self.offset = 0
                    }
                }
                isSearchFocused = false
            }
    }
    
    private func setupKeyboardObservers() {
        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillShowNotification, object: nil, queue: .main) { notification in
            guard let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
            self.keyboardHeight = keyboardFrame.height
            if isSearchFocused {
                withAnimation(.easeOut(duration: 0.16)) {
                    self.offset = 0
                }
            }
        }
        
        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillHideNotification, object: nil, queue: .main) { _ in
            self.keyboardHeight = 0
        }
    }
    
    private func removeKeyboardObservers() {
        NotificationCenter.default.removeObserver(self)
    }
}

struct ExpandableSearchView_Previews: PreviewProvider {
    static var previews: some View {
        ExpandableSearchView(profilePictureURL: "https://example.com/profile_picture.jpg")
    }
}
