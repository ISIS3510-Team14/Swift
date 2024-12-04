import SwiftUI
import UIKit
import FirebaseFirestore


class CameraViewmodel: ObservableObject {
    
    @Published var image: UIImage?
    @Published var responseTextBin: String = ""
    @Published var showResponsePopup: Bool = false
    @Published var trashTypeIconDetected: TrashTypeIcon = TrashTypeIcon(type: "Error", icon: "xmark.octagon.fill")
    @Published var noResponse: Bool = false
    @Published var noResponse1: Bool = false
    @Published var timerCount: Int = 0
    @Published var timerActive: Bool = false
    @Published var error: Bool = false
    @Published var showConnectivityPopup: Bool = false
    @Published var showPoints: Bool = false
    @Published var noBins: Bool = true

    var userProfile: UserProfile
    
    init(userProfile: UserProfile) {
        self.userProfile = userProfile
    }
    
    

    
    @Published var networkMonitor = NetworkMonitor.shared
    
    struct SavedImage: Codable {
        let fileName: String
        let date: Date
    }
    
    private let metadataFileName = "savedImages_.json"

    func saveImageLocally() {
        guard let image = image else { return }
        guard let imageData = image.jpegData(compressionQuality: 1.0) else { return }
        
        // Generar un nombre único para el archivo usando la fecha y hora actual
        let fileName = "SavedImage_\(Date().timeIntervalSince1970).jpg"
        
        // Obtener la URL del directorio de documentos
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let fileURL = documentsDirectory.appendingPathComponent(fileName)
    
        
        do {
            // Guardar la imagen en el directorio de documentos
            try imageData.write(to: fileURL)
            print("Imagen guardada en: \(fileURL.path)")
            
            // Guardar los metadatos de la imagen
            saveImageMetadata(fileName: fileName, date: Date())
        } catch {
            print("Error al guardar la imagen: \(error)")
        }
    }

    private func saveImageMetadata(fileName: String, date: Date) {
        var savedImages = loadSavedImages()
        let newImage = SavedImage(fileName: fileName, date: date)
        savedImages.append(newImage)
        
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let metadataFileURL = documentsDirectory.appendingPathComponent(metadataFileName)
        
        do {
            let data = try JSONEncoder().encode(savedImages)
            try data.write(to: metadataFileURL)
        } catch {
            print("Error al guardar los metadatos de la imagen: \(error)")
        }
    }
    
    func loadSavedImages() -> [SavedImage] {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let metadataFileURL = documentsDirectory.appendingPathComponent(metadataFileName)
        
        // Verificar si el archivo de metadatos existe
        if !FileManager.default.fileExists(atPath: metadataFileURL.path) {
            return [] // Devuelve una lista vacía si el archivo no existe
        }
        
        do {
            let data = try Data(contentsOf: metadataFileURL)
            let savedImages = try JSONDecoder().decode([SavedImage].self, from: data)
            return savedImages
        } catch {
            print("Error al cargar los metadatos de las imágenes: \(error)")
            return []
        }
    }
    
    // Función para eliminar una imagen y su metadata asociada
    func deleteImageWithMetadata(fileName: String) {
        // Eliminar el archivo de imagen
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let fileURL = documentsDirectory.appendingPathComponent(fileName)
        
        do {
            try FileManager.default.removeItem(at: fileURL)
            print("Imagen eliminada: \(fileURL.path)")
        } catch {
            print("Error al eliminar la imagen: \(error)")
        }
        
        // Cargar y actualizar el archivo de metadata
        var savedImages = loadSavedImages()
        savedImages.removeAll { $0.fileName == fileName }
        
        // Guardar la lista de imágenes actualizada sin la imagen eliminada
        let metadataFileURL = documentsDirectory.appendingPathComponent(metadataFileName)
        
        do {
            let data = try JSONEncoder().encode(savedImages)
            try data.write(to: metadataFileURL)
            print("Metadata actualizada y guardada después de eliminar la imagen.")
        } catch {
            print("Error al actualizar los metadatos de la imagen: \(error)")
        }
    }
    func reset() {
        showPoints = false
        noBins = true
        
        noResponse = false
        noResponse1 = false
        error = false
    }
    func takePhoto(image: UIImage) {
        reset()
        
        showPoints = false
        noBins = true
        
        self.image = image
        
        let photoBase64 = convertImageToBase64String(img: image)
        var responseTextTrash = "Waiting for response..."
        
        let dispatchGroup = DispatchGroup()

        // Primer request
        let promptTrashType = "Answer for the image: Which of these types of trash is the user taking the picture holding?: \(trashTypesString). Answer only with the type."

        dispatchGroup.enter()
        RequestService().sendRequest(prompt: promptTrashType, photoBase64: photoBase64) { response in
            DispatchQueue.main.async {
                responseTextTrash = response ?? "No response"
                dispatchGroup.leave()
            }
        }
        
        // Manejo de llegada de requests
        dispatchGroup.notify(queue: .main) {
            
            if !self.networkMonitor.isConnected {
                print("Conexión perdida durante el primer request")
                self.showConnectivityPopup = true
                dispatchGroup.leave()
                return
            }
            
            print("Request 1: ")
            print(responseTextTrash)
            self.showPoints = false
            self.noBins = true
            self.handleTrashTypeResponse(responseTextTrash, photoBase64: photoBase64, dispatchGroup: dispatchGroup)
        }
        
    }
    
    private func handleTrashTypeResponse(_ responseTextTrash: String, photoBase64: String, dispatchGroup: DispatchGroup) {
        var i = 0
        for trashType in trashTypes {
            if responseTextTrash.contains(trashType.type) {
 
                self.trashTypeIconDetected = trashType
                let foundTrashType = trashType.type
                
                // Segundo request
                let promptBinType = "Answer for the image: What is the most appropriate bin to dispose of a \(foundTrashType) in?. If there are no bins on the image, answer 'No bins are shown'. Otherwise, your answer must be short: at most two short sentences."
                
                dispatchGroup.enter()
                RequestService().sendRequest(prompt: promptBinType, photoBase64: photoBase64) { response in
                    DispatchQueue.main.async {
                        self.responseTextBin = response ?? "No response"
                        //self.showResponsePopup = true
                        dispatchGroup.leave()
                    }
                }
                
                // Mostrar el resultado después de ambos requests
                dispatchGroup.notify(queue: .main) {
                    
                    if !self.networkMonitor.isConnected {
                        print("Conexión perdida durante el segundo request")
                        self.showConnectivityPopup = true
                        dispatchGroup.leave()
                        return
                    }
                    
                    print("Request 2: ")
                    print(self.responseTextBin)
                    if self.responseTextBin.lowercased() != "No bins are shown".lowercased() &&
                        self.responseTextBin.lowercased() != "No bins are shown.".lowercased() {
                        self.noBins = false
                        print("SI HAY BINS")
                        print(Array(self.responseTextBin))
                        
                        self.showPoints = true
                        
                        DispatchQueue.global(qos: .userInitiated).async {
                            // enviar assign
                            self.assignPointsToUser()
                        }
                    }
                    
                    else {
                        self.noResponse = true
                        print("NoResponse")
                        print(self.noResponse)
                        self.noResponse = true
                        print(self.noResponse)

                    }
                    
                    self.showResponsePopup = true // Mostrar el popup cuando llega la segunda respuesta
                }
                break
            } else {
                i += 1
            }
        }
        
        if i == trashTypes.count {
            print("FIN LOOP: no se encontro ninguno")
            
            self.noResponse1 = true
            self.showResponsePopup = true
        }
    }
    
    private func convertImageToBase64String(img: UIImage) -> String {
        return img.jpegData(compressionQuality: 1)?.base64EncodedString() ?? ""
    }
    
    func startTimer() {
        self.timerCount = 0
        self.timerActive = true
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
            if self.showResponsePopup {
                timer.invalidate()
            } else {
                self.timerCount += 1
                if self.timerCount >= 20 {
                    timer.invalidate()
                    self.error = true
                    self.showResponsePopup = true
                }
            }
        }
    }
    
    func sendScanEvent(scanTime: Int, thrashType: String) {
        let db = Firestore.firestore()
        let data: [String: Any] = [
            "time": scanTime,
            "trash_type": thrashType,
        ]
        
        db.collection("scans").addDocument(data: data) { error in
            if let error = error {
                print("Error adding document: \(error)")
            } else {
                print("Document added successfully")
            }
        }
    }
    
    func assignPointsToUser() {
        
        let db = Firestore.firestore()
        let userDocRef = db.collection("users").document(self.userProfile.email)

        // Configurar el formato de la fecha como yyyy-MM-dd
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let currentDate = dateFormatter.string(from: Date())

        // Actualizar los puntos
        userDocRef.getDocument { document, error in
            if let document = document, document.exists, var data = document.data() {
                // Actualizar el historial de puntos
                var history = (data["points"] as? [String: Any])?["history"] as? [[String: Any]] ?? []
                history.append(["date": currentDate, "points": 50])

                // Actualizar el total de puntos
                var totalPoints = (data["points"] as? [String: Any])?["total"] as? Int ?? 0
                totalPoints += 50

                // Escribir los cambios en Firestore
                userDocRef.updateData([
                    "points.history": history,
                    "points.total": totalPoints
                ]) { error in
                    DispatchQueue.main.async {
                        if let error = error {
                            print("Error al asignar puntos: \(error)")
                        } else {
                            print("+50 puntos asignados exitosamente al usuario.")
                        }
                    }
                }
            } else {
                DispatchQueue.main.async {
                    print("El documento del usuario no existe o tiene un error: \(String(describing: error))")
                }
            }
        }   
        
    }
    
    


}

