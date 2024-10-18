import SwiftUI
import UIKit



struct CameraView: View {
    
    @StateObject private var viewModel = CameraViewmodel()
    let profilePictureURL: String
    
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
                    parent.image = uiImage
                    self.parent.viewModel.takePhoto(image: uiImage)
                    parent.presentationMode.wrappedValue.dismiss()
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
            // Header con la información del perfil
            TopBarView(profilePictureURL: profilePictureURL)
            
            // Contenido principal: mostrar la cámara o la imagen capturada
            ZStack {
                if let capturedImage = viewModel.image {
                    Image(uiImage: capturedImage)
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    
                    // Mostrar el timer encima de la imagen capturada
                    VStack {
                        Spacer()
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle())
                            .scaleEffect(2)
                            .padding(10)
                        Spacer()
                    }
                    .onAppear {
                        viewModel.startTimer()
                    }
                } else {
                    // Vista de la cámara cuando no se ha capturado ninguna imagen
                    CameraPickerView(image: $viewModel.image,
                                     responseTextBin: $viewModel.responseTextBin,
                                     showResponsePopup: $viewModel.showResponsePopup,
                                     trashTypeIconDetected: $viewModel.trashTypeIconDetected,
                                     noResponse: $viewModel.noResponse,
                                     viewModel: viewModel
                    )
                    .frame(maxHeight: .infinity)
                }
                
                // Mostrar popup cuando llega la respuesta
                if viewModel.showResponsePopup {
                    CameraPopupView(
                        icon: viewModel.trashTypeIconDetected.icon,
                        title: viewModel.trashTypeIconDetected.type != "Error" ? "Item Detected!" : "Could not detect an item!",
                        trashType: viewModel.trashTypeIconDetected.type,
                        responseText: viewModel.trashTypeIconDetected.type != "Error" ? viewModel.responseTextBin : "Could not detect an item :(",
                        showResponsePopup: $viewModel.showResponsePopup,
                        image: $viewModel.image,
                        trashTypeIconDetected: $viewModel.trashTypeIconDetected,
                        timerActive: $viewModel.timerActive,
                        error: viewModel.error,
                        noResponse: viewModel.noResponse
                    )
                }
            }
        }
        .statusBar(hidden: false)
    }
}

