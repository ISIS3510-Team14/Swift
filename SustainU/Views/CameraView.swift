import SwiftUI
import UIKit

struct CameraView: UIViewControllerRepresentable {
    
    @Binding var image: UIImage?
    @Binding var responseTextBin: String // Vinculación para el texto de respuesta del segundo request
    @Binding var showResponsePopup: Bool // Vinculación para mostrar el popup
    @Binding var trashTypeIconDetected: TrashTypeIcon // Vinculación para mostrar el popup
    @Binding var noResponse: Bool // Vinculación para mostrar el popup
    @Environment(\.presentationMode) var presentationMode
        
    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        
        let parent: CameraView
        
        init(parent: CameraView) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let uiImage = info[.originalImage] as? UIImage {
                parent.image = uiImage
                
                // Procesar la imagen aquí (base64 y requests)
                func convertImageToBase64String(img: UIImage) -> String {
                    return img.jpegData(compressionQuality: 1)?.base64EncodedString() ?? ""
                }
                
                let photoBase64: String = convertImageToBase64String(img: uiImage)

                var responseTextTrash: String = "Waiting for response..."
  
                let dispatchGroup = DispatchGroup()

                // Tipo de basura
                let promptTrashType = "Answer for the image: Which of these types of trash is the user taking the picture holding?: \(trashTypesString). Answer only with the type."
                
                print("Primer request")
                // Primer request
                dispatchGroup.enter()
                RequestService().sendRequest(prompt: promptTrashType, photoBase64: photoBase64) { response in
                    DispatchQueue.main.async {
                        responseTextTrash = response ?? "No response"
                        dispatchGroup.leave()
                    }
                }

                // Llegada del primer request
                dispatchGroup.notify(queue: .main) {
                    
                    print("LLEGO PRIMER REQUEST: ", responseTextTrash)
                    var i = 0
                    // Verificación del tipo de basura
                    for trashType in trashTypes {
                        
                        // Coincidencia
                        if responseTextTrash.contains(trashType.type) {
                            print("BINGOOOOOOOOOOOOOOOOO")
                            self.parent.trashTypeIconDetected = trashType
                            let foundTrashType = trashType.type
                            let promptBinType = "Answer for the image: What is the most appropriate bin to dispose of a \(foundTrashType) in?. Indicate if none of the present bins are appropriate. Your answer must be short: only one sentence."
                            
                            print("Segundo request")
                            dispatchGroup.enter()
                            RequestService().sendRequest(prompt: promptBinType, photoBase64: photoBase64) { response in
                                DispatchQueue.main.async {
                                    self.parent.responseTextBin = response ?? "No response"
                                    dispatchGroup.leave()
                                }
                            }
                            
                            // Llegada del segundo request
                            dispatchGroup.notify(queue: .main) {
                                self.parent.showResponsePopup = true // Mostrar el popup cuando llega la segunda respuesta
                                print("LLEGO SEGUNDO REQUEST: ", self.parent.responseTextBin)
                            }
                            break
                        }
                        
                        else {
                            print("Item i = \(i)")
                            i+=1
                        }
                    }
                    
                    if i==trashTypes.count {
                        print(responseTextTrash)
                        self.parent.noResponse = true
                        self.parent.showResponsePopup = true
                    }
                }
            }
            parent.presentationMode.wrappedValue.dismiss()
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

struct CameraViewWithHeader: View {
    
    @State private var image: UIImage? // Imagen capturada
    @State private var responseTextBin: String = "" // Respuesta del segundo request
    @State private var showResponsePopup: Bool = false // Controla si el popup se muestra
    @State private var trashTypeIconDetected: TrashTypeIcon = TrashTypeIcon(type: "Error", icon: "xmark.octagon.fill")
    @State private var timerCount: Int = 0 // Contador del timer
    @State private var timerActive: Bool = false // Controla si el timer está activo
    @State private var error: Bool = false
    @State private var noResponse: Bool = false
    let profilePictureURL: String
    
    // Función para iniciar el temporizador
    func startTimer() {
        timerCount = 0 // Reinicia el contador
        timerActive = true
        for family in UIFont.familyNames.sorted() {
            let names = UIFont.fontNames(forFamilyName: family)
            print("Family: \(family) Font names: \(names)")
        }
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
            if showResponsePopup {
                timer.invalidate() // Detener el temporizador cuando el popup aparece
            } else {
                timerCount += 1 // Incrementar el contador cada segundo
                print("Tiempo transcurrido: \(timerCount) segundos") // Imprimir el tiempo en consola
                
                // Mostrar el popup si se alcanzan los 30 segundos
                if timerCount >= 30 {
                    timer.invalidate() // Detener el temporizador
                    error = true
                    showResponsePopup = true // Mostrar el popup automáticamente

                }
            }
        }
        
    }

    var body: some View {
        VStack {
            TopBarView(profilePictureURL: profilePictureURL)
            // Mostrar la imagen capturada en pantalla completa si existe
            ZStack {
                if let capturedImage = image {
                    Image(uiImage: capturedImage)
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    // Mostrar el timer encima de la imagen capturada
                    VStack {
                        Spacer()
                        ProgressView() // Botón de carga circular
                            .progressViewStyle(CircularProgressViewStyle()) // Estilo circular
                            .scaleEffect(2) // Escalar el indicador de carga
                            .padding(10)
                        Spacer()
                    }
                    .onAppear {
                        startTimer() // Iniciar el timer cuando se muestra la imagen
                    }
                } else {
                    // El componente de la cámara cuando no hay imagen
                    CameraView(image: $image, responseTextBin: $responseTextBin, showResponsePopup: $showResponsePopup, trashTypeIconDetected: $trashTypeIconDetected, noResponse: $noResponse)
                        .frame(maxHeight: .infinity) // Hacer que el CameraView ocupe todo el espacio disponible
                }
                
                
                // Mostrar popup encima de la imagen cuando se recibe la respuesta
                if showResponsePopup {
                    CameraPopupView(
                        icon: trashTypeIconDetected.icon,
                        title: trashTypeIconDetected.type != "Error" ? "Item Detected!" : "Could not detect an item!",
                        trashType: trashTypeIconDetected.type,
                        responseText: trashTypeIconDetected.type != "Error" ? responseTextBin : "Could not detect an item :(",
                        showResponsePopup: $showResponsePopup, // Vincular para manejar la visibilidad del popup
                        image: $image, // Vincular para restablecer la imagen
                        trashTypeIconDetected: $trashTypeIconDetected, // Vincular para restablecer el tipo de residuo
                        timerActive: $timerActive, // Vincular para detener el temporizador
                        error: error,
                        noResponse: noResponse
                    )
                }
            }
        }
        .statusBar(hidden: false) // Asegurar que la barra de estado sea visible
    }
}

