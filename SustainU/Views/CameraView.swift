import SwiftUI
import UIKit

struct CameraView: UIViewControllerRepresentable {
    
    @Binding var image: UIImage?
    @Binding var responseTextBin: String // Vinculación para el texto de respuesta del segundo request
    @Binding var showResponsePopup: Bool // Vinculación para mostrar el popup
    @Binding var trashTypeIconDetected: TrashTypeIcon // Vinculación para mostrar el popup
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
                parent.responseTextBin = "Waiting for response..." // Inicializar el texto del popup con un valor por defecto

                let dispatchGroup = DispatchGroup()

                // Tipo de basura
                let promptTrashType = "Answer for the image: Which of these types of trash is the user taking the picture holding?: \(trashTypesString). Answer only with the type."

                // Primer request
                dispatchGroup.enter()
                RequestService().sendRequest(prompt: promptTrashType, photoBase64: photoBase64) { response in
                    DispatchQueue.main.async {
                        responseTextTrash = response ?? "No response"
                        dispatchGroup.leave()
                    }
                }

                // Después del primer request
                dispatchGroup.notify(queue: .main) {
                    
                    print("LLEGO EL PRIMER PROMPT: ", responseTextTrash)
                    var i = 0
                    // Verificación del tipo de basura
                    for trashType in trashTypes {
                        if responseTextTrash.contains(trashType.type) {
                            
                            print("BINGOOOOOOOOOOOOOOOOO")
                            
                            self.parent.trashTypeIconDetected = trashType
                            let foundTrashType = trashType.type
                            let promptBinType = "Answer for the image: What is the most appropriate bin to dispose of a \(foundTrashType) in?. Indicate if none of the present bins are appropriate. Your answer must be short: no more than two sentences. "
                            
                            dispatchGroup.enter()
                            RequestService().sendRequest(prompt: promptBinType, photoBase64: photoBase64) { response in
                                DispatchQueue.main.async {
                                    self.parent.responseTextBin = response ?? "No response"
                                    dispatchGroup.leave()
                                }
                            }
                            
                            // Mostrar el resultado después de ambos requests
                            dispatchGroup.notify(queue: .main) {
                                self.parent.showResponsePopup = true // Mostrar el popup cuando llega la segunda respuesta
                            }
                            break
                        }
                        else {
                            print("i = \(i)")
                            i+=1
                        }
                    }
                    if i==trashTypes.count {
                        print(responseTextTrash)
                        self.parent.showResponsePopup = true // Mostrar el popup cuando llega la segunda respuesta
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
    //@State private var detectedWasteType: String = "Electronic Waste" // Ejemplo del tipo de desecho detectado
    //@State private var wasteIcon: String = "laptopcomputer" // Ejemplo de SF Symbol para el icono
    @State private var trashTypeIconDetected: TrashTypeIcon = TrashTypeIcon(type: "Error", icon: "xmark.octagon.fill")
    //@State private var titulo: String = ""
    @State private var timerCount: Int = 0 // Contador del timer
    @State private var timerActive: Bool = false // Controla si el timer está activo
    
    // Función para iniciar el temporizador
    func startTimer() {
        timerCount = 0 // Reinicia el contador
        timerActive = true
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
            if showResponsePopup {
                timer.invalidate() // Detener el temporizador cuando el popup aparece
            } else {
                timerCount += 1 // Incrementar el contador cada segundo
            }
        }
    }

    var body: some View {
        VStack {
            // Header con dos imágenes
            HStack {
                Image("logoBigger")
                    .resizable()
                    .frame(width: 40, height: 40)
                
                Spacer()
                
                Image("ProfilePicture")
                    .resizable()
                    .frame(width: 40, height: 40)
                    .clipShape(Circle())
            }
            .padding() // Padding para el header
            
            
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
                        Text("Time elapsed: \(timerCount) seconds")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding(10)
                            .background(Color.black.opacity(0.7))
                            .cornerRadius(10)
                            .padding(.bottom, 20) // Posicionar el timer en la parte inferior
                    }
                    .onAppear {
                        startTimer() // Iniciar el timer cuando se muestra la imagen
                    }
                } else {
                    // El componente de la cámara cuando no hay imagen
                    CameraView(image: $image, responseTextBin: $responseTextBin, showResponsePopup: $showResponsePopup, trashTypeIconDetected: $trashTypeIconDetected)
                        .frame(maxHeight: .infinity) // Hacer que el CameraView ocupe todo el espacio disponible
                }
                
                
                // Mostrar popup encima de la imagen cuando se recibe la respuesta
                if showResponsePopup {
                    
                    VStack(spacing: 20) { // Espaciado reducido entre los elementos
                                                
                        Text(trashTypeIconDetected.type != "Error" ? "Item Detected!" :
                                "Could not detect an item!")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.black)
                            .padding(.top)
                        
                        HStack(spacing: 15) { // Reducir el espacio entre el icono y el texto
                            Image(systemName: trashTypeIconDetected.icon) // Ícono del tipo de desecho
                                .resizable()
                                .frame(width: 40, height: 40)
                                .foregroundColor(.green)
                            
                            VStack(alignment: .leading, spacing: 5) { // Reducir el espacio entre los textos
                                Text(trashTypeIconDetected.type) // Tipo de desecho
                                    .font(.title2)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.black)
                                
                                Text(trashTypeIconDetected.type != "Error" ?  responseTextBin:
                                        "Could not detect an item :(") // respuesta de la peticion
                                    .font(.body)
                                    .foregroundColor(.gray)
                            }
                        }
                        .padding(.horizontal)
                        //.background(Color.white)
                        //.cornerRadius(15)
                        //.shadow(radius: 10)

                        // Botón Cerrar en verde, separado del borde inferior
                        Button(action: {
                            showResponsePopup = false // Ocultar popup
                            image = nil
                            trashTypeIconDetected = TrashTypeIcon(type: "Error", icon: "xmark.octagon.fill") // Restaurar el valor predeterminado
                            timerActive = false // Detener el timer

                        }) {
                            Text("Cerrar")
                                .foregroundColor(.white)
                                .padding()
                                .frame(maxWidth: 200) // Ajustar el ancho del botón
                                .background(Color.green) // Hacer el botón verde
                                .cornerRadius(10)
                        }
                        .padding(.horizontal)
                        .padding(.bottom)
                    }
                    .frame(maxWidth: .infinity)
                    .background(Color.white)
                    .cornerRadius(15)
                    .shadow(radius: 10)
                    .padding(.horizontal, 20) // Ajustar el padding horizontal para dar más espacio
                    //.padding(.vertical, 10) // Reducir el padding vertical para que no esté tan separado
                }
            }
            
        }
    }
}
