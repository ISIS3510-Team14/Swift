import SwiftUI
import MapKit

struct CollectionPoint: Identifiable {
    let id = UUID()
    let name: String
    let location: String
    let materials: String
    let latitude: Double
    let longitude: Double
    
    var coordinate: CLLocationCoordinate2D{
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}

struct ExpandableSearchView: View {
    @StateObject private var locationManager = LocationManager()
    @State private var searchText = ""
    @State private var offset: CGFloat = 500 // Inicia parcialmente visible
    @GestureState private var draggingOffset: CGFloat = 0
    @State private var userTrackingMode: MKUserTrackingMode = .none
    @State private var selectedPoint: CollectionPoint?
    @State private var isNavigatingToDetail = false
    
    let maxHeight: CGFloat = UIScreen.main.bounds.height - 100
    let minHeight: CGFloat = 500
    
    let collectionPoints = [
        CollectionPoint(name: "El Bobo", location: "Between buildings C and B", materials: "Recyclables and Organic", latitude: 37.3347302, longitude: -122.0089189),
        CollectionPoint(name: "Carlos Pacheco Devia", location: "3rd and 4th floor near the elevators", materials: "Organic, cardboard, glass", latitude: 4.601836, longitude: -74.065348),
        CollectionPoint(name: "Mario Laserna building", location: "6th floor, next to the elevators", materials: "Organic, plastic and cardboard", latitude: 4.602814, longitude: -74.064313),
        CollectionPoint(name: "La Gata Golosa", location: "between restrooms and basketball court", materials: "Containers, organic and plastic", latitude: 4.603397, longitude: -74.066441)
    ]
    
    var filteredPoints: [CollectionPoint] {
        if searchText.isEmpty {
            return collectionPoints
        } else {
            return collectionPoints.filter { point in
                point.name.lowercased().contains(searchText.lowercased())
            }
        }
    }
    
    var body: some View {
        NavigationView {
            ZStack(alignment: .bottom) {
                MapView(locationManager: locationManager,
                        userTrackingMode: $userTrackingMode,
                        collectionPoints: collectionPoints,
                        onAnnotationTap: { point in
                            self.selectedPoint = point
                            self.isNavigatingToDetail = true
                        })
                    .edgesIgnoringSafeArea(.all)
                
                VStack(spacing: 15) {
                    Capsule()
                        .fill(Color.secondary)
                        .frame(width: 60, height: 4)
                        .padding(.top, 8)
                    
                    Text("Find collection points near you")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    SearchBarView(searchText: $searchText)
                    
                    ScrollView {
                        LazyVStack(alignment: .leading, spacing: 20) {
                            ForEach(filteredPoints) { point in
                                NavigationLink(destination: CollectionPointDetailView(point: point)) {
                                    VStack(alignment: .leading, spacing: 4) {
                                        HStack {
                                            Image(systemName: "mappin.circle.fill")
                                                .foregroundColor(.green)
                                            Text(point.name)
                                                .font(.headline)
                                        }
                                        Text(point.location)
                                            .font(.subheadline)
                                            .foregroundColor(.gray)
                                        Text(point.materials)
                                            .font(.subheadline)
                                            .foregroundColor(.blue)
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
                .offset(y: max(self.offset + self.draggingOffset, 0))
                .gesture(
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
                        }
                )
                
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
            }
            .background(
                NavigationLink(destination: Group {
                    if let point = selectedPoint {
                        CollectionPointDetailView(point: point)
                    }
                }, isActive: $isNavigatingToDetail) {
                    EmptyView()
                }
            )
        }
    }
}

struct ExpandableSearchView_Previews: PreviewProvider {
    static var previews: some View {
        ExpandableSearchView()
    }
}
