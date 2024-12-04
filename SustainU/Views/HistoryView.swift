//
//  HistoryView.swift
//  SustainU
//
//  Created by Duarte Mantilla Ernesto Jose on 27/11/24.
//

import Foundation
import SwiftUI

struct HistoryView: View {
    @StateObject private var viewModel = HistoryViewModel()
    var userEmail: String

    var body: some View {
        VStack {
            Text("Recycling History")
                .font(.largeTitle)
                .padding()

            Text("User Email: \(userEmail)")
                .font(.subheadline)
                .foregroundColor(.gray)
                .padding()

            if viewModel.history.isEmpty {
                Text("No recycling history found.")
                    .foregroundColor(.gray)
                    .padding()
            } else {
                List(viewModel.history, id: \.date) { entry in
                    VStack(alignment: .leading) {
                        Text("Date: \(entry.date)")
                            .font(.headline)
                        Text("Points: \(entry.points)")
                            .font(.subheadline)
                    }
                }
            }

            Divider()
                .padding(.vertical)

            
            .padding()
        }
        .onAppear {
            viewModel.fetchRecyclingHistory(for: userEmail)
        }
    }
}
