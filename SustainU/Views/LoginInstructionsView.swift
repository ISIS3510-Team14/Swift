//
//  LoginInstructionsView.swift
//  SustainU
//
//  Created by Duarte Mantilla Ernesto Jose on 1/11/24.
//

import Foundation
import SwiftUI

struct LoginInstructionsView: View {
    @Environment(\.presentationMode) var presentationMode  // To dismiss the view

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Login Instructions")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.bottom, 20)
            
            Text("1. The email must belong to the @uniandes.edu.co domain.")
                .font(.body)
            Text("2. The email must not contain special characters except \".\", \"-\", and \"_\".")
                .font(.body)
            Text("3. The name must not have special characters and must have between 3 and 50 characters.")
                .font(.body)
            
            Spacer()
            
            // Optional: Add a close button
            Button(action: {
                presentationMode.wrappedValue.dismiss()
            }) {
                Text("Close")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color("greenLogoColor"))
                    .cornerRadius(15.0)
            }
            .padding(.bottom, 20)
        }
        .padding()
        .navigationBarTitle("", displayMode: .inline)  // Hide the navigation bar title
    }
}

struct LoginInstructionsView_Previews: PreviewProvider {
    static var previews: some View {
        LoginInstructionsView()
    }
}