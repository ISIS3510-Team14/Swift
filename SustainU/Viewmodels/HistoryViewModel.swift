import Foundation
import FirebaseFirestore

class HistoryViewModel: ObservableObject {
    @Published var history: [HistoryEntry] = []
    @Published var totalPoints: Int = 0
    @Published var logs: [String] = []
    @Published var uniqueDaysCount: Int = 0
    
    private var listener: ListenerRegistration?
    private let db = Firestore.firestore()
    
    // Keys for UserDefaults
    private let historyKey = "recycling_history"
    private let totalPointsKey = "total_points"
    private let uniqueDaysKey = "unique_days"
    private let lastUpdateKey = "last_update_timestamp"
    
    init() {
        loadFromLocalStorage()
    }
    
    private func loadFromLocalStorage() {
        if let savedHistory = UserDefaults.standard.data(forKey: historyKey) {
            do {
                let decodedHistory = try JSONDecoder().decode([HistoryEntry].self, from: savedHistory)
                DispatchQueue.main.async {
                    self.history = decodedHistory
                    self.totalPoints = UserDefaults.standard.integer(forKey: self.totalPointsKey)
                    self.uniqueDaysCount = UserDefaults.standard.integer(forKey: self.uniqueDaysKey)
                }
                addLog("Loaded data from local storage")
            } catch {
                addLog("Error decoding local data: \(error)")
            }
        }
    }
    
    private func saveToLocalStorage() {
        do {
            let encodedHistory = try JSONEncoder().encode(history)
            UserDefaults.standard.set(encodedHistory, forKey: historyKey)
            UserDefaults.standard.set(totalPoints, forKey: totalPointsKey)
            UserDefaults.standard.set(uniqueDaysCount, forKey: uniqueDaysKey)
            UserDefaults.standard.set(Date(), forKey: lastUpdateKey)
            addLog("Saved data to local storage")
        } catch {
            addLog("Error encoding data for local storage: \(error)")
        }
    }
    
    func fetchRecyclingHistory(for userEmail: String) {
        print("Fetching history for: \(userEmail)")
        
        // First load from local storage
        loadFromLocalStorage()
        
        let docRef = db.collection("users").document(userEmail)
        listener?.remove()
        
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
                
                let normalizedDate = dateStr.trimmingCharacters(in: .whitespaces)
                                         .replacingOccurrences(of: "\"", with: "")
                
                return HistoryEntry(date: normalizedDate, points: points)
            }
            
            let total = history.reduce(0) { $0 + ((($1["points"] as? Int) ?? 0)) }
            let uniqueDays = Set(parsedHistory.map { $0.date.trimmingCharacters(in: .whitespaces)
                                                          .replacingOccurrences(of: "\"", with: "") })
            
            DispatchQueue.main.async {
                self.history = parsedHistory
                self.totalPoints = total
                self.uniqueDaysCount = uniqueDays.count
                // Save to local storage after updating from Firebase
                self.saveToLocalStorage()
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
            self.uniqueDaysCount = 0
            
            // Clear local storage
            UserDefaults.standard.removeObject(forKey: self.historyKey)
            UserDefaults.standard.removeObject(forKey: self.totalPointsKey)
            UserDefaults.standard.removeObject(forKey: self.uniqueDaysKey)
            UserDefaults.standard.removeObject(forKey: self.lastUpdateKey)
            
            self.addLog("History cleared from both memory and local storage")
        }
    }
    
    func shouldRefreshFromFirebase() -> Bool {
        guard let lastUpdate = UserDefaults.standard.object(forKey: lastUpdateKey) as? Date else {
            return true
        }
        
        let hoursSinceLastUpdate = Calendar.current.dateComponents([.hour], from: lastUpdate, to: Date()).hour ?? 0
        return hoursSinceLastUpdate >= 1 // Refresh if more than 1 hour has passed
    }
    
    deinit {
        listener?.remove()
    }
}
