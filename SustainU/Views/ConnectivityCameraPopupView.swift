import SwiftUI

struct ConnectivityCameraPopup: View {
    @Binding var showPopup: Bool
    @Binding var selectedTab: Int // Añade este Binding para cambiar la pestaña,
    var viewModel: CameraViewmodel // Añadimos el viewModel para acceder a la función de guardado
    var onCancel: () -> Void // Closure que se llama al cancelar

    var body: some View {
        VStack(spacing: 20) {
            Text("No Internet Connection")
                .font(.headline)
                .foregroundColor(.black)

            Text("Please check your connection and try again.")
                .font(.subheadline)
                .foregroundColor(.gray)

            Text("What would you like to do?")
                .font(.subheadline)
                .foregroundColor(.black)

            Button(action: {
                // Acción para revisar consejos de reciclaje
                selectedTab = 3 // Cambiar a la pestaña de Recycle
                onCancel() // Llama a la acción de cancelar y reiniciar
            }) {
                Text("Review Recycling Tips")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color("greenLogoColor"))
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }

            Button(action: {
                viewModel.saveImageLocally() // Llama a la función para guardar la imagen localmente
                onCancel() // Llama a la acción de cancelar y reiniciar
            }) {
                Text("Save Picture for Later")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color("greenLogoColor"))
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }

            Button(action: {
                onCancel() // Llama a la acción de cancelar y reiniciar
            }) {
                Text("Cancel")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.gray.opacity(0.2))
                    .foregroundColor(.black)
                    .cornerRadius(8)
            }
        }
        .padding()
        .frame(maxWidth: 300)
        .background(Color.white)
        .cornerRadius(15)
        .shadow(radius: 10)
        .padding(.horizontal, 20)
        .padding(.vertical, 10)
    }
}
