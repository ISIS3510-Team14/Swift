//
//  RecycleCardView.swift
//  SustainU
//
//  Created by Duarte Mantilla Ernesto Jose on 5/11/24.
//

import Foundation
import SwiftUI

struct RecycleCardView: View {
    var title: String
    var iconName: String
    var description: String
    
    var body: some View {
        VStack {
            Image(iconName) // Cambia a tu imagen personalizada si es necesario
                .resizable()
                .frame(width: 40, height: 40)
            Text(title)
                .font(.headline)
            Text(description)
                .font(.subheadline)
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.white)
        .cornerRadius(10)
        .shadow(radius: 2)
    }
}
