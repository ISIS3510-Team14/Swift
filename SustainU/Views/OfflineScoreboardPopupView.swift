import SwiftUI

struct OfflineScoreboardPopupView: View {
    @Binding var isPresented: Bool
    
    var body: some View {
        ZStack {
            if isPresented {
                Color.black.opacity(0.4)
                    .edgesIgnoringSafeArea(.all)
                
                VStack {
                    VStack(spacing: 20) {
                        Text("Offline")
                            .font(.title3.bold())
                            .foregroundColor(.black)
                        
                        Text("You are not connected to Wi-Fi. The scoreboard shown won't be up-to-date.")
                            .font(.body)
                            .multilineTextAlignment(.center)
                            .foregroundColor(.black)
                            .padding(.horizontal)
                        
                        Button(action: {
                            isPresented = false
                        }) {
                            Text("OK")
                                .fontWeight(.medium)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background(Color("greenLogoColor"))
                                .cornerRadius(10)
                        }
                        .padding(.horizontal)
                    }
                    .padding(.vertical, 24)
                    .frame(width: 280)
                    .background(Color.white)
                    .cornerRadius(12)
                }
                .transition(.scale.combined(with: .opacity))
            }
        }
        .animation(.easeInOut, value: isPresented)
    }
}

