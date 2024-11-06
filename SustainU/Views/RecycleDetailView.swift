//
//  RecycleDetailView.swift
//  SustainU
//
//  Created by Duarte Mantilla Ernesto Jose on 5/11/24.
//

import Foundation
import SwiftUI

struct RecycleDetailView: View {
    var title: String
    var iconName: String
    var fact: String
    var trashCanImageName: String
    var disposalInfo: String
    var extraInfo: String
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                HStack {
                    Text(title)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    Image(iconName)
                        .resizable()
                        .frame(width: 30, height: 30)
                }
                
                Text(fact)
                    .font(.headline)
                    .padding()
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(10)
                
                Text(disposalInfo)
                    .font(.body)
                    .multilineTextAlignment(.center)
                
                Image(trashCanImageName)
                    .resizable()
                    .frame(width: 60, height: 100)
                
                Text(extraInfo)
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .padding(.top, 10)
            }
            .padding()
        }
        .navigationBarTitle(title, displayMode: .inline)
    }
}
