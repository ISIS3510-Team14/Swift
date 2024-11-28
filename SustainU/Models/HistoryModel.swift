//
//  HistoryModel.swift
//  SustainU
//
//  Created by Duarte Mantilla Ernesto Jose on 27/11/24.
//

import Foundation

struct HistoryEntry: Identifiable, Codable {
    let id = UUID()  // Generar un identificador único para SwiftUI
    let date: String  // Fecha en formato "YYYY-MM-DD"
    let points: Int  // Puntos obtenidos ese día
}
