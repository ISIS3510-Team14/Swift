import SwiftUI
import MapKit

struct ExpandableSearchView: View {
    @StateObject private var viewModel = ExpandableSearchViewModel()
    @FocusState private var isSearchFocused: Bool
    @GestureState private var draggingOffset: CGFloat = 0
    
    let profilePictureURL: String
    
    var body: some View {
        NavigationView {
            ZStack(alignment: .top) {
                MapView(locationManager: viewModel.locationManager,
                        userTrackingMode: $viewModel.userTrackingMode,
                        collectionPoints: viewModel.collectionPointViewModel.collectionPoints,
                        onAnnotationTap: { point in
                            viewModel.selectedPoint = point
                            viewModel.isNavigatingToDetail = true
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
                        
                        SearchBarView(searchText: $viewModel.searchText, focused: $isSearchFocused)
                            .focused($isSearchFocused)
                            .onChange(of: viewModel.searchText) { newValue in
                                viewModel.isTyping = !newValue.isEmpty
                            }
                        
                        ScrollView {
                            LazyVStack(alignment: .leading, spacing: 20) {
                                ForEach(viewModel.filteredPoints) { point in
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
                                    .onTapGesture {
                                        viewModel.collectionPointViewModel.incrementCount(for: point)
                                        viewModel.selectedPoint = point
                                        viewModel.isNavigatingToDetail = true
                                    }
                                }
                            }
                            .padding(.top)
                        }
                    }
                    .padding(.horizontal)
                    .frame(maxHeight: viewModel.maxHeight)
                    .background(Color(.systemBackground))
                    .cornerRadius(15)
                    .offset(y: viewModel.calculateOffset(with: draggingOffset))
                    .gesture(dragGesture)
                }
                
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Button(action: {
                            viewModel.startUpdatingLocation()
                            viewModel.userTrackingMode = .follow
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
                viewModel.startUpdatingLocation()
                viewModel.setupKeyboardObservers()
            }
            .onDisappear {
                viewModel.removeKeyboardObservers()
            }
            .background(
                NavigationLink(
                    destination: CollectionPointDetailView(
                        point: viewModel.selectedPoint ?? CollectionPoint(
                            id: UUID(),
                            name: "",
                            location: "",
                            materials: "",
                            latitude: 0,
                            longitude: 0,
                            imageName: "default-image",
                            documentID: "",
                            count: 0
                        )
                    ),
                    isActive: $viewModel.isNavigatingToDetail
                ) {
                    EmptyView()
                }
            )
        }
    }
    
    private var dragGesture: some Gesture {
        DragGesture()
            .updating($draggingOffset) { value, state, _ in
                state = value.translation.height
            }
            .onEnded { value in
                viewModel.handleDragGesture(value: value)
                isSearchFocused = false
            }
    }
}

struct ExpandableSearchView_Previews: PreviewProvider {
    static var previews: some View {
        ExpandableSearchView(profilePictureURL: "https://example.com/profile_picture.jpg")
    }
}
