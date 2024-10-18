import SwiftUI
import MapKit
import Combine

class ExpandableSearchViewModel: ObservableObject {
    @Published var searchText = ""
    @Published var offset: CGFloat = 500
    @Published var userTrackingMode: MKUserTrackingMode = .none
    @Published var selectedPoint: CollectionPoint?
    @Published var isNavigatingToDetail = false
    @Published var keyboardHeight: CGFloat = 0
    @Published var isSearchFocused = false
    @Published var isTyping = false
    
    let locationManager = LocationManager()
    let collectionPointViewModel = CollectionPointViewModel()
    
    let maxHeight: CGFloat = UIScreen.main.bounds.height - 100
    let minHeight: CGFloat = 500
    
    var draggingOffset: CGFloat = 0
    
    var filteredPoints: [CollectionPoint] {
        let filtered = searchText.isEmpty ? collectionPointViewModel.collectionPoints : collectionPointViewModel.collectionPoints.filter { point in
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
    
    func calculateOffset(with draggingOffset: CGFloat) -> CGFloat {
        if isSearchFocused || isTyping {
            return 0  // Move to the top when focused or typing
        } else {
            return offset + draggingOffset
        }
    }
    
    func handleDragGesture(value: DragGesture.Value) {
        withAnimation(.spring()) {
            let dragHeight = value.translation.height
            let dragThreshold = maxHeight * 0.3
            if dragHeight > dragThreshold {
                offset = minHeight
            } else if -dragHeight > dragThreshold {
                offset = 0
            } else if offset > minHeight / 2 {
                offset = minHeight
            } else {
                offset = 0
            }
        }
        isSearchFocused = false
        isTyping = false  // Reset typing state when dragging ends
    }
    
    func setupKeyboardObservers() {
        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillShowNotification, object: nil, queue: .main) { [weak self] notification in
            guard let self = self, let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
            self.keyboardHeight = keyboardFrame.height
            withAnimation(.easeOut(duration: 0.16)) {
                self.offset = 0
            }
        }
        
        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillHideNotification, object: nil, queue: .main) { [weak self] _ in
            self?.keyboardHeight = 0
            if !(self?.isTyping ?? false) {
                withAnimation(.easeOut(duration: 0.16)) {
                    self?.offset = self?.minHeight ?? 500
                }
            }
        }
    }
    
    func removeKeyboardObservers() {
        NotificationCenter.default.removeObserver(self)
    }
    
    func startUpdatingLocation() {
        locationManager.startUpdatingLocation()
    }
}
