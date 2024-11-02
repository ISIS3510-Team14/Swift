import SwiftUI
import MapKit

struct ExpandableSearchView: View {
    @StateObject private var viewModel = ExpandableSearchViewModel()
    @FocusState private var isSearchFocused: Bool
    @GestureState private var draggingOffset: CGFloat = 0
    @ObservedObject var collectionPointViewModel: CollectionPointViewModel
    @State private var selectedPoint: CollectionPoint?
    @State private var showingDetail = false
    
    let profilePictureURL: String
    
    var body: some View {
        NavigationView {
            ZStack(alignment: .top) {
                MapView(locationManager: viewModel.locationManager,
                       userTrackingMode: $viewModel.userTrackingMode,
                       collectionPoints: collectionPointViewModel.collectionPoints,
                       onAnnotationTap: { point in
                           selectedPoint = point
                           showingDetail = true
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
                                    Button(action: {
                                        selectedPoint = point
                                        showingDetail = true
                                        collectionPointViewModel.incrementCount(for: point)
                                    }) {
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
            .navigationViewStyle(StackNavigationViewStyle())
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
                    destination: Group {
                        if let point = selectedPoint {
                            CollectionPointDetailView(point: point)
                        }
                    },
                    isActive: $showingDetail
                ) { EmptyView() }
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
