import SwiftUI

struct CameraPopupView: View {
    var icon: String
    var title: String
    var trashType: String
    var responseText: String
    @Binding var showResponsePopup: Bool // Vinculación para manejar el cierre del popup
    @Binding var image: UIImage? // Para limpiar la imagen
    @Binding var trashTypeIconDetected: TrashTypeIcon // Para restaurar el tipo de residuo
    @Binding var timerActive: Bool // Para detener el temporizador

    
    // Inicializador para casos predeterminados (ERROR o NoResponse)
    init(icon: String, title: String, trashType: String, responseText: String,
         showResponsePopup: Binding<Bool>, image: Binding<UIImage?>, trashTypeIconDetected: Binding<TrashTypeIcon>, timerActive: Binding<Bool>,
         error: Bool = false, noResponse: Bool = false) {
        
        _showResponsePopup = showResponsePopup
        _image = image
        _trashTypeIconDetected = trashTypeIconDetected
        _timerActive = timerActive
        
        // Si es un error, configurar con valores predeterminados
        if error {
            self.icon = "xmark.octagon.fill"
            self.title = "Error!"
            self.trashType = "An error ocurred :("
            self.responseText = "Please try again"
        } else if noResponse {
            // Si es un NoResponse, configurar con valores predeterminados
            self.icon = "xmark.octagon.fill"
            self.title = "Could not detect an item!"
            self.trashType = ""
            self.responseText = "Please try again"
        } else {
            self.icon = icon
            self.title = title
            self.trashType = trashType
            self.responseText = responseText
        }
    }
    
    var body: some View {
        VStack(spacing: 5) {
            Text(title)
                .font(.system(size: 20, weight: .bold)) // ANTES DE REDUCIR: estaba en 24
                .foregroundColor(.black)
                .padding(.top, 5) // ANTES DE REDUCIR: no habia 5

            HStack(spacing: 15) {
                Image(systemName: icon)
                    .resizable()
                    .frame(width: 40, height: 40)
                    .foregroundColor(Color("greenLogoColor"))

                VStack(alignment: .leading, spacing: 5) {
                    Text(trashType)
                        //.font(.system(size: 18, weight: .bold))
                        //.font(.system(size: 18))
                        //.font(.custom("Montserrat-VariableFont_wght", size: 18))
                        //.font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.black)

                    Text(responseText)
                        .font(.body)
                        .foregroundColor(.gray)
                }
            }
            .padding(.horizontal, 10)

            Button(action: {
                showResponsePopup = false // Cerrar el popup
                image = nil
                trashTypeIconDetected = TrashTypeIcon(type: "Error", icon: "xmark.octagon.fill") // Restaurar el valor predeterminado
                timerActive = false // Detener el timer
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
