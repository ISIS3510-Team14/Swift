import SwiftUI
import UIKit
import FirebaseFirestore

class CameraViewmodel: ObservableObject {
    @Published var image: UIImage?
    @Published var responseTextBin: String = ""
    @Published var showResponsePopup: Bool = false
    @Published var trashTypeIconDetected: TrashTypeIcon = TrashTypeIcon(type: "Error", icon: "xmark.octagon.fill")
    @Published var noResponse: Bool = false
    @Published var timerCount: Int = 0
    @Published var timerActive: Bool = false
    @Published var error: Bool = false
    @Published var showConnectivityPopup: Bool = false
    
    @Published var networkMonitor = NetworkMonitor.shared
    private let db = Firestore.firestore()
    
    struct SavedImage: Codable {
        let fileName: String
        let date: Date
    }
    
    private let metadataFileName = "savedImages_.json"

    func saveImageLocally() {
        guard let image = image else { return }
        guard let imageData = image.jpegData(compressionQuality: 1.0) else { return }
        
        let fileName = "SavedImage_\(Date().timeIntervalSince1970).jpg"
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let fileURL = documentsDirectory.appendingPathComponent(fileName)
        
        do {
            try imageData.write(to: fileURL)
            print("Imagen guardada en: \(fileURL.path)")
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
        
        if !FileManager.default.fileExists(atPath: metadataFileURL.path) {
            return []
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
    
    func deleteImageWithMetadata(fileName: String) {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let fileURL = documentsDirectory.appendingPathComponent(fileName)
        
        do {
            try FileManager.default.removeItem(at: fileURL)
            print("Imagen eliminada: \(fileURL.path)")
        } catch {
            print("Error al eliminar la imagen: \(error)")
        }
        
        var savedImages = loadSavedImages()
        savedImages.removeAll { $0.fileName == fileName }
        
        let metadataFileURL = documentsDirectory.appendingPathComponent(metadataFileName)
        do {
            let data = try JSONEncoder().encode(savedImages)
            try data.write(to: metadataFileURL)
            print("Metadata actualizada y guardada después de eliminar la imagen.")
        } catch {
            print("Error al actualizar los metadatos de la imagen: \(error)")
        }
    }
    
    private func updateUserPoints(userEmail: String) {
        let docRef = db.collection("users").document(userEmail)
        
        // Get current date in yyyy-mm-dd format
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let currentDate = dateFormatter.string(from: Date())
        
        // Create new history entry
        let newHistoryEntry: [String: Any] = [
            "date": currentDate,
            "points": 50
        ]
        
        docRef.getDocument { [weak self] snapshot, error in
            guard let self = self else { return }
            
            if let error = error {
                print("Error getting document: \(error)")
                return
            }
            
            if let document = snapshot, document.exists {
                // Document exists, update it
                var currentTotal = 0
                var history: [[String: Any]] = []
                
                if let points = document.data()?["points"] as? [String: Any] {
                    currentTotal = points["total"] as? Int ?? 0
                    history = points["history"] as? [[String: Any]] ?? []
                }
                
                // Add new history entry and update total
                history.append(newHistoryEntry)
                let newTotal = currentTotal + 50
                
                let updateData: [String: Any] = [
                    "points.total": newTotal,
                    "points.history": history
                ]
                
                docRef.updateData(updateData) { error in
                    if let error = error {
                        print("Error updating document: \(error)")
                    } else {
                        print("Document successfully updated")
                    }
                }
            } else {
                // Document doesn't exist, create it
                let initialData: [String: Any] = [
                    "points": [
                        "total": 50,
                        "history": [newHistoryEntry]
                    ],
                    "user_id": userEmail
                ]
                
                docRef.setData(initialData) { error in
                    if let error = error {
                        print("Error creating document: \(error)")
                    } else {
                        print("Document successfully created")
                    }
                }
            }
        }
    }
    
    func takePhoto(image: UIImage) {
        self.image = image
        let photoBase64 = convertImageToBase64String(img: image)
        var responseTextTrash = "Waiting for response..."
        
        let dispatchGroup = DispatchGroup()
        let promptTrashType = "Answer for the image: Which of these types of trash is the user taking the picture holding?: \(trashTypesString). Answer only with the type."

        dispatchGroup.enter()
        RequestService().sendRequest(prompt: promptTrashType, photoBase64: photoBase64) { response in
            DispatchQueue.main.async {
                responseTextTrash = response ?? "No response"
                dispatchGroup.leave()
            }
        }
        
        dispatchGroup.notify(queue: .main) {
            if !self.networkMonitor.isConnected {
                print("Conexión perdida durante el primer request")
                self.showConnectivityPopup = true
                dispatchGroup.leave()
                return
            }
            
            print("Request 1: ")
            print(responseTextTrash)
            self.handleTrashTypeResponse(responseTextTrash, photoBase64: photoBase64, dispatchGroup: dispatchGroup)
        }
    }
    
    private func handleTrashTypeResponse(_ responseTextTrash: String, photoBase64: String, dispatchGroup: DispatchGroup) {
        var i = 0
        for trashType in trashTypes {
            if responseTextTrash.contains(trashType.type) {
                self.trashTypeIconDetected = trashType
                let foundTrashType = trashType.type
                
                let promptBinType = "Answer for the image: What is the most appropriate bin to dispose of a \(foundTrashType) in?. Indicate if none of the present bins are appropriate. Your answer must be short: at most two short sentences."
                
                dispatchGroup.enter()
                RequestService().sendRequest(prompt: promptBinType, photoBase64: photoBase64) { response in
                    DispatchQueue.main.async {
                        self.responseTextBin = response ?? "No response"
                        dispatchGroup.leave()
                    }
                }
                
                dispatchGroup.notify(queue: .main) {
                    if !self.networkMonitor.isConnected {
                        print("Conexión perdida durante el segundo request")
                        self.showConnectivityPopup = true
                        dispatchGroup.leave()
                        return
                    }
                    
                    print("Request 2: ")
                    print(self.responseTextBin)
                    self.showResponsePopup = true
                }
                break
            } else {
                i += 1
            }
        }
        
        if i == trashTypes.count {
            self.noResponse = true
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
    
    func sendScanEvent(scanTime: Int, thrashType: String, userEmail: String) {
        let scanData: [String: Any] = [
            "time": scanTime,
            "trash_type": thrashType,
        ]
        
        db.collection("scans").addDocument(data: scanData) { [weak self] error in
            if let error = error {
                print("Error adding scan document: \(error)")
            } else {
                print("Scan document added successfully")
                // After successful scan, update user points
                self?.updateUserPoints(userEmail: userEmail)
            }
        }
    }
}
