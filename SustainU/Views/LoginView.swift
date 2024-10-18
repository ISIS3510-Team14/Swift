import SwiftUI

struct LoginView: View {
    @ObservedObject var viewModel: LoginViewModel
    
    var body: some View {
        VStack {
            Spacer()
            // Mostrar la imagen al inicio de la vista
            Image("peopleCartoonLogo")
                .resizable()
                .scaledToFit()
                .frame(width: 300, height: 300)
            
            Image("logoBigger")
                .resizable()
                .scaledToFit()
                .frame(width: 200, height: 200)
                .padding(.bottom, 40)
            
            Text("SustainU")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.black)
                .padding(.bottom, 40)
            
            Button(action: {
                viewModel.authenticate()
            }) {
                Text("Log in / Sign up")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .frame(width: 220, height: 60)
                    .background(Color.green)
                    .cornerRadius(15.0)
            }
            .padding(.bottom, 20)

            Spacer()
        }
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        // Usar la instancia Singleton en lugar de crear una nueva
        LoginView(viewModel: LoginViewModel.shared)
    }
}
