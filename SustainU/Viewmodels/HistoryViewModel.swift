import Foundation
import FirebaseFirestore

class HistoryViewModel: ObservableObject {
    @Published var history: [HistoryEntry] = []
    @Published var totalPoints: Int = 0
    @Published var logs: [String] = []
    private var listener: ListenerRegistration?
    @Published var uniqueDaysCount: Int = 0
    
    private let db = Firestore.firestore()
    
    func fetchRecyclingHistory(for userEmail: String) {
        print("Fetching history for: \(userEmail)")
        let docRef = db.collection("users").document(userEmail)
        
        // Cancelar el listener anterior si existe
        listener?.remove()
        
        // Configurar nuevo listener
        listener = docRef.addSnapshotListener { [weak self] documentSnapshot, error in
            guard let self = self else { return }
            
            if let error = error {
                print("Error fetching: \(error.localizedDescription)")
                self.addLog("Error fetching document: \(error.localizedDescription)")
                return
            }
            
            guard let document = documentSnapshot else {
                print("No document found")
                self.addLog("No document found")
                return
            }
            
            print("Document received: \(String(describing: document.data()))")
            self.parseDocument(document)
        }
    }
    
    private func parseDocument(_ document: DocumentSnapshot) {
        if let data = document.data(),
           let points = data["points"] as? [String: Any],
           let history = points["history"] as? [[String: Any]] {
            
            let parsedHistory: [HistoryEntry] = history.compactMap { entry in
                guard let dateStr = entry["date"] as? String,
                      let points = entry["points"] as? Int else {
                    return nil
                }
                
                // Normalizar la fecha eliminando comillas extras y espacios
                let normalizedDate = dateStr.trimmingCharacters(in: .whitespaces)
                                         .replacingOccurrences(of: "\"", with: "")
                
                return HistoryEntry(date: normalizedDate, points: points)
            }
            
            let total = history.reduce(0) { $0 + ((($1["points"] as? Int) ?? 0)) }
            
            // Crear un Set con las fechas normalizadas
            let uniqueDays = Set(parsedHistory.map { $0.date.trimmingCharacters(in: .whitespaces)
                                                          .replacingOccurrences(of: "\"", with: "") })
            
            print("Unique days: \(uniqueDays)") // Para debug
            
            DispatchQueue.main.async {
                self.history = parsedHistory
                self.totalPoints = total
                self.uniqueDaysCount = uniqueDays.count
                print("Updated unique days count: \(uniqueDays.count)") // Para debug
            }
        }
    }
    
    private func addLog(_ message: String) {
        DispatchQueue.main.async {
            let timestamp = DateFormatter.localizedString(from: Date(), dateStyle: .none, timeStyle: .medium)
            self.logs.append("[\(timestamp)] \(message)")
            
            if self.logs.count > 100 {
                self.logs.removeFirst(self.logs.count - 100)
            }
        }
    }
    
    func clearHistory() {
        DispatchQueue.main.async {
            self.history = []
            self.totalPoints = 0
            self.logs = []
            self.addLog("History cleared")
        }
    }
    
    deinit {
        listener?.remove()
    }
}
