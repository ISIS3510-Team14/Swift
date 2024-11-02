import SwiftUI

struct ConnectivityPopupView: View {
    @Binding var showResponsePopup: Bool
    var retryAction: () -> Void
    
    var body: some View {
        VStack(spacing: 5) {
            // Header con título y botón de cerrar
            HStack {
                Text("No Internet Connection")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.black)
                
                Spacer()
                
                Button(action: {
                    showResponsePopup = false
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.gray)
                        .font(.system(size: 24))
                }
            }
            .padding(.horizontal)
            .padding(.top, 16)

            HStack(spacing: 15) {
                Image(systemName: "wifi.slash")
                    .resizable()
                    .frame(width: 40, height: 40)
                    .foregroundColor(Color("greenLogoColor"))

                VStack(alignment: .leading, spacing: 5) {
                    Text("First Time Setup Required")
                        .fontWeight(.semibold)
                        .foregroundColor(.black)

                    Text("Please connect to the internet to load Green Points for the first time.")
                        .font(.body)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.leading)
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 10)

            HStack(spacing: 10) {
                Button(action: {
                    showResponsePopup = false
                }) {
                    Text("Close")
                        .foregroundColor(.white)
                        .padding(.vertical, 8)
                        .padding(.horizontal, 16)
                        .frame(maxWidth: .infinity)
                        .background(Color.gray)
                        .cornerRadius(10)
                }
                
                Button(action: retryAction) {
                    Text("Retry")
                        .foregroundColor(.white)
                        .padding(.vertical, 8)
                        .padding(.horizontal, 16)
                        .frame(maxWidth: .infinity)
                        .background(Color("greenLogoColor"))
                        .cornerRadius(10)
                }
            }
            .padding(.horizontal)
            .padding(.bottom, 16)
        }
        .frame(maxWidth: 320)
        .background(Color.white)
        .cornerRadius(15)
        .shadow(radius: 10)
        .padding(.horizontal, 20)
    }
}
