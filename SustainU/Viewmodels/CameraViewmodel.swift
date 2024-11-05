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
    
    func takePhoto(image: UIImage) {
        

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
            print(responseTextTrash)
            self.handleTrashTypeResponse(responseTextTrash, photoBase64: photoBase64, dispatchGroup: dispatchGroup)
        }
        
    }
    
    private func handleTrashTypeResponse(_ responseTextTrash: String, photoBase64: String, dispatchGroup: DispatchGroup) {
        var i = 0
        for trashType in trashTypes {
            if responseTextTrash.contains(trashType.type) {
                print("BINGOOOOOOOOO")
                self.trashTypeIconDetected = trashType
                let foundTrashType = trashType.type
                
                // Segundo request
                let promptBinType = "Answer for the image: What is the most appropriate bin to dispose of a \(foundTrashType) in?. Indicate if none of the present bins are appropriate. Your answer must be short: at most two short sentences."
                
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
                    print("Llegó segundo request")
                    print(self.responseTextBin)
                    self.showResponsePopup = true // Mostrar el popup cuando llega la segunda respuesta
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
                if self.timerCount >= 30 {
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
}
