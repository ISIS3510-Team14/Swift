import SwiftUI
import UIKit

struct CameraView: View {
    @StateObject private var connectivityManager = ConnectivityManager.shared
    @StateObject private var viewModel = CameraViewmodel()
    @ObservedObject private var networkMonitor = NetworkMonitor.shared
    @State private var showConnectivityPopup = false
    let profilePictureURL: String
    let userEmail: String // Added user email property
    @Binding var selectedTab: Int
    @State private var showCameraPicker = true
    @Binding var selectedImage: UIImage?
    
    private func resetCamera() {
        print("resetCamera")
        viewModel.image = nil
        viewModel.showConnectivityPopup = false
    }
    
    struct CameraPickerView: UIViewControllerRepresentable {
        @Binding var image: UIImage?
        @Binding var responseTextBin: String
        @Binding var showResponsePopup: Bool
        @Binding var trashTypeIconDetected: TrashTypeIcon
        @Binding var noResponse: Bool
        @ObservedObject var viewModel: CameraViewmodel
        @Environment(\.presentationMode) var presentationMode
            
        class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
            let parent: CameraPickerView
            
            init(parent: CameraPickerView) {
                self.parent = parent
            }
            
            func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
                if let uiImage = info[.originalImage] as? UIImage {
                    if !parent.viewModel.networkMonitor.isConnected {
                        parent.image = uiImage
                        self.parent.viewModel.showConnectivityPopup = true
                    } else {
                        parent.image = uiImage
                        self.parent.viewModel.takePhoto(image: uiImage)
                        parent.presentationMode.wrappedValue.dismiss()
                    }
                }
            }
            
            func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
                parent.presentationMode.wrappedValue.dismiss()
            }
        }
        
        func makeCoordinator() -> Coordinator {
            return Coordinator(parent: self)
        }
        
        func makeUIViewController(context: Context) -> UIImagePickerController {
            let picker = UIImagePickerController()
            picker.delegate = context.coordinator
            picker.sourceType = .camera
            return picker
        }
        
        func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    }
    
    var body: some View {
        VStack {
            TopBarView(profilePictureURL: profilePictureURL, connectivityManager: ConnectivityManager.shared)
            
            ZStack {
                if let capturedImage = viewModel.image {
                    Image(uiImage: capturedImage)
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    
                    if !viewModel.showConnectivityPopup {
                        VStack {
                            Spacer()
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle())
                                .scaleEffect(2)
                                .padding(10)
                                .background(Color.black.opacity(0.5))
                                .tint(Color("greenLogoColor"))
                            Spacer()
                            Text("Identifying waste: \(viewModel.timerCount) seconds elapsed")
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding(10)
                                .background(Color.black.opacity(0.5))
                                .cornerRadius(10)
                                .padding(.bottom, 20)
                        }
                        .onAppear {
                            viewModel.startTimer()
                        }
                    }
                } else {
                    CameraPickerView(
                        image: $viewModel.image,
                        responseTextBin: $viewModel.responseTextBin,
                        showResponsePopup: $viewModel.showResponsePopup,
                        trashTypeIconDetected: $viewModel.trashTypeIconDetected,
                        noResponse: $viewModel.noResponse,
                        viewModel: viewModel
                    )
                    .frame(maxHeight: .infinity)
                }
                
                if viewModel.showResponsePopup {
                    CameraPopupView(
                        icon: viewModel.trashTypeIconDetected.icon,
                        title: viewModel.trashTypeIconDetected.type != "No Item Detected" ? "Item Detected!" : "Could not detect an item!",
                        trashType: viewModel.trashTypeIconDetected.type,
                        responseText: viewModel.trashTypeIconDetected.type != "No Item Detected" ? viewModel.responseTextBin : "Could not detect an item :(",
                        showResponsePopup: $viewModel.showResponsePopup,
                        image: $viewModel.image,
                        trashTypeIconDetected: $viewModel.trashTypeIconDetected,
                        timerActive: $viewModel.timerActive,
                        error: viewModel.error,
                        noResponse: viewModel.noResponse
                    )
                    .onAppear {
                        print("sendScanEvent pre")
                        print(viewModel.timerCount, viewModel.trashTypeIconDetected.type)
                        // Only update points if there was a successful detection
                        if !viewModel.error && !viewModel.noResponse {
                            viewModel.sendScanEvent(
                                scanTime: viewModel.timerCount,
                                thrashType: viewModel.trashTypeIconDetected.type,
                                userEmail: userEmail
                            )
                        }
                        print("sendScanEvent pos")
                    }
                }
                
                if viewModel.showConnectivityPopup {
                    ConnectivityCameraPopup(
                        showPopup: $viewModel.showConnectivityPopup,
                        selectedTab: $selectedTab,
                        viewModel: viewModel,
                        onCancel: resetCamera
                    )
                }
            }
        }
        .statusBar(hidden: false)
        .onChange(of: selectedImage) { newImage in
            if let newImage = newImage {
                viewModel.takePhoto(image: newImage)
                selectedImage = nil
            }
        }
    }
}
