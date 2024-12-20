import SwiftUI



struct CameraPopupView: View {
    var icon: String
    var title: String
    var trashType: String
    var responseText: String
    @Binding var showResponsePopup: Bool
    @Binding var image: UIImage?
    @Binding var trashTypeIconDetected: TrashTypeIcon
    @Binding var timerActive: Bool
    var viewModel: CameraViewmodel // Ahora recibe el ViewModel
    
    var userProfile: UserProfile


    // Inicializador para casos predeterminados (ERROR o NoResponse)
    init(icon: String, title: String, trashType: String, responseText: String,
         showResponsePopup: Binding<Bool>, image: Binding<UIImage?>, trashTypeIconDetected: Binding<TrashTypeIcon>, timerActive: Binding<Bool>,
         viewModel: CameraViewmodel, userProfile: UserProfile) {
        
        self.viewModel = viewModel
        _showResponsePopup = showResponsePopup
        _image = image
        _trashTypeIconDetected = trashTypeIconDetected
        _timerActive = timerActive
        
        self.userProfile = userProfile

        
        print("CameraPopupView init")
        // Si es un error, configurar con valores predeterminados
        if viewModel.error {
            print("error")
            self.icon = "xmark.octagon.fill"
            self.title = "Error!"
            self.trashType = "No Item Detected"
            self.responseText = "Please try again"
        } else if viewModel.noResponse && viewModel.noBins {
            print("noResponse")
            // Si es un NoResponse, configurar con valores predeterminados
            self.icon = icon
            self.title = "An item was detected"
            self.trashType = trashType
            self.responseText = responseText
        } else if viewModel.noResponse1 {
            print("noResponse")
            // Si es un NoResponse, configurar con valores predeterminados
            self.icon = "xmark.octagon.fill"
            self.title = "Could not detect an item!"
            self.trashType = "No Item Detected"
            self.responseText = "Please try again"
        }
        else {
            print("else")
            self.icon = icon
            self.title = title
            self.trashType = trashType
            self.responseText = responseText
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
                }
            }
            .padding(.horizontal, 10)

            if viewModel.showPoints && !viewModel.noBins {
                Text("+50 points!")
                    .font(.headline)
                    .foregroundColor(Color("greenLogoColor"))
                    .padding()
                    .transition(.scale) // Animación al mostrar los puntos
            } else {
                Text("No points")
                    .font(.headline)
                    .foregroundColor(Color("redLogoColor"))
                    .padding()
                    .transition(.scale) // Animación al mostrar los puntos
            }

            Button(action: {
                showResponsePopup = false
                image = nil
                trashTypeIconDetected = TrashTypeIcon(type: "Error", icon: "xmark.octagon.fill")
                timerActive = false
                viewModel.showPoints = false
                viewModel.noBins = true
                viewModel.noResponse1 = false
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
