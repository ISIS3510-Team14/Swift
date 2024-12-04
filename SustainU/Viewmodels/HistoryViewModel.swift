//
//  HistoryViewModel.swift
//  SustainU
//
//  Created by Duarte Mantilla Ernesto Jose on 27/11/24.
//

import Foundation
import FirebaseFirestore

class HistoryViewModel: ObservableObject {
    @Published var history: [HistoryEntry] = []
    @Published var totalPoints: Int = 0
    @Published var logs: [String] = []  // Para almacenar los logs
    
    private let db = Firestore.firestore()
    
    func fetchRecyclingHistory(for userEmail: String) {
        addLog("Fetching history for email: \(userEmail)")
        
        let docRef = Firestore.firestore().collection("users").document(userEmail)
        docRef.getDocument { document, error in
            if let error = error {
                self.addLog("Error fetching document: \(error.localizedDescription)")
                return
            }
            
            guard let document = document, document.exists else {
                self.addLog("Document does not exist for user: \(userEmail)")
                return
            }
            
            self.addLog("Document found for user: \(userEmail)")
            self.addLog("Document data: \(document.data() ?? [:])")
            
            // Decoding history
            if let data = document.data(),
               let points = data["points"] as? [String: Any],
               let historyArray = points["history"] as? [[String: Any]] {
                
                self.addLog("Raw history data: \(historyArray)")
                
                let parsedHistory: [HistoryEntry] = historyArray.compactMap { entry in
                    guard let date = entry["date"] as? String,
                          let points = entry["points"] as? Int else {
                        self.addLog("Error parsing entry: \(entry)")
                        return nil
                    }
                    return HistoryEntry(date: date, points: points)
                }
                
                self.addLog("Parsed history: \(parsedHistory)")
                DispatchQueue.main.async {
                    self.history = parsedHistory
                }
            } else {
                self.addLog("No valid history data found.")
            }
        }
    }
    
    // Definición del método addLog
    private func addLog(_ message: String) {
        DispatchQueue.main.async {
            self.logs.append(message)
        }
    }
}
