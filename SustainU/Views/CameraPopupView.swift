import SwiftUI

struct CameraPopupView: View {
    var icon: String
    var title: String
    var trashType: String
    var responseText: String
    var pointsMessage: String // New property for points message
    @Binding var showResponsePopup: Bool
    @Binding var image: UIImage?
    @Binding var trashTypeIconDetected: TrashTypeIcon
    @Binding var timerActive: Bool
    
    init(icon: String, title: String, trashType: String, responseText: String,
         showResponsePopup: Binding<Bool>, image: Binding<UIImage?>,
         trashTypeIconDetected: Binding<TrashTypeIcon>, timerActive: Binding<Bool>,
         error: Bool = false, noResponse: Bool = false) {
        
        _showResponsePopup = showResponsePopup
        _image = image
        _trashTypeIconDetected = trashTypeIconDetected
        _timerActive = timerActive
        
        if error {
            self.icon = "xmark.octagon.fill"
            self.title = "Error!"
            self.trashType = "No Item Detected"
            self.responseText = "Please try again"
            self.pointsMessage = "No points gained"
        } else if noResponse {
            self.icon = "xmark.octagon.fill"
            self.title = "Could not detect an item!"
            self.trashType = "No Item Detected"
            self.responseText = "Please try again"
            self.pointsMessage = "No points gained"
        } else {
            self.icon = icon
            self.title = title
            self.trashType = trashType
            self.responseText = responseText
            self.pointsMessage = "+50 points"
        }
    }
    
    var body: some View {
        VStack(spacing: 5) {
            Text(title)
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.black)
                .padding(.top, 5)

            HStack(spacing: 15) {
                Image(systemName: icon)
                    .resizable()
                    .frame(width: 40, height: 40)
                    .foregroundColor(Color("greenLogoColor"))

                VStack(alignment: .leading, spacing: 5) {
                    Text(trashType)
                        .fontWeight(.semibold)
                        .foregroundColor(.black)

                    Text(responseText)
                        .font(.body)
                        .foregroundColor(.gray)
                        
                    Text(pointsMessage) // Added points message
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(pointsMessage == "No points gained" ? .red : .green)
                        .padding(.top, 2)
                }
            }
            .padding(.horizontal, 10)

            Button(action: {
                showResponsePopup = false
                image = nil
                trashTypeIconDetected = TrashTypeIcon(type: "Error", icon: "xmark.octagon.fill")
                timerActive = false
            }) {
                Text("Close")
                    .foregroundColor(.white)
                    .padding(.vertical, 8)
                    .padding(.horizontal, 16)
                    .frame(maxWidth: 150)
                    .background(Color("greenLogoColor"))
                    .cornerRadius(10)
            }
            .padding(.horizontal)
            .padding(.bottom)
        }
        .frame(maxWidth: 300)
        .background(Color.white)
        .cornerRadius(15)
        .shadow(radius: 10)
        .padding(.horizontal, 20)
        .padding(.vertical, 10)
    }
}
