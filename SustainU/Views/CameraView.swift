import SwiftUI
import UIKit



struct CameraView: View {
    
    
    @StateObject private var connectivityManager = ConnectivityManager.shared
    @StateObject private var viewModel = CameraViewmodel()
    @ObservedObject private var networkMonitor = NetworkMonitor.shared // Monitoreo de red
    @State private var showConnectivityPopup = false // Estado para el popup de conectividad
    let profilePictureURL: String
    @Binding var selectedTab: Int // Añade selectedTab como Binding
    @State private var showCameraPicker = true // Controla la visibilidad de CameraPicker para reiniciar
    @Binding var selectedImage: UIImage? // Añade selectedImage como Binding para recibir la imagen

    
    // Función para reiniciar el contenido de la cámara
    private func resetCamera() {
        print("resetCamera")
        viewModel.image = nil // Limpia la imagen capturada
        viewModel.showConnectivityPopup = false // Cierra el popup de conectividad si estaba abierto
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
                    

                    // Verifica la conectividad después de capturar la imagen
                    if !parent.viewModel.networkMonitor.isConnected {
                        // Muestra el popup de conectividad si no hay conexión
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
            // Header con la información del perfil
            TopBarView(profilePictureURL: profilePictureURL,connectivityManager: ConnectivityManager.shared)
            
            // Contenido principal: mostrar la cámara o la imagen capturada
            ZStack {
                if let capturedImage = viewModel.image {
                    Image(uiImage: capturedImage)
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    
                    if !viewModel.showConnectivityPopup {
                        // Mostrar el timer encima de la imagen capturada
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
                                .padding(.bottom, 20) // Posicionar el timer en la parte inferior
                        }
                        .onAppear {
                            viewModel.startTimer()
                        }
                    }

                } else { // Mostrar el CameraPicker si está habilitado
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
                        viewModel.sendScanEvent(scanTime: viewModel.timerCount, thrashType: viewModel.trashTypeIconDetected.type)
                        print("sendScanEvent pos")
                    }
                }
                
                // Mostrar el popup de conectividad cuando no hay internet
                if viewModel.showConnectivityPopup {
                    ConnectivityCameraPopup(showPopup: $viewModel.showConnectivityPopup, 
                                            selectedTab: $selectedTab,
                                            viewModel: viewModel, // Pasar el viewModel aquí
                                            onCancel: resetCamera // Llama a resetCamera al cancelar
                    )
                }
                
            }
        }
        .statusBar(hidden: false)
        .onChange(of: selectedImage) { newImage in
             if let newImage = newImage {
                 viewModel.takePhoto(image: newImage) // Llamar a takePhoto cuando se selecciona una imagen
                 selectedImage = nil // Limpiar selectedImage para evitar múltiples llamadas
             }
         }
    }
}
