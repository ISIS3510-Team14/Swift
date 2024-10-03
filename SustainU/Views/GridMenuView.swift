import SwiftUI

struct GridMenuView: View {
    let menuItems = [
        ("See green points", "map"),
        ("See Scoreboard", "list.bullet"),
        ("What can I recycle?", "arrow.2.circlepath.circle"),
        ("History", "calendar")
    ]
    
    var body: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 20) {
            ForEach(menuItems, id: \.0) { item in
                Button(action: {
                    // Acción para cada botón
                }) {
                    VStack {
                        Image(systemName: item.1)
                            .resizable()
                            .frame(width: 40, height: 40)
                            .padding()
                        Text(item.0)
                            .font(.headline)
                            .foregroundColor(.black)
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(15.0)
                }
            }
        }
        .padding(.horizontal)
    }
}

struct GridMenuView_Previews: PreviewProvider {
    static var previews: some View {
        GridMenuView()
    }
}
