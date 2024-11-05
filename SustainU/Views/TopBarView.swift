import SwiftUI

struct TopBarView: View {
    var profilePictureURL: String
    @ObservedObject var connectivityManager: ConnectivityManager
    var onProfileTap: () -> Void = {}
    
    
    var body: some View {
        HStack {
            Image("logoBigger")
                .resizable()
                .scaledToFit()
                .frame(width: 50, height: 50)

            Spacer()

            // Connectivity indicator
            Image(systemName: "circle.fill")
                .resizable()
                .frame(width: 15, height: 15)
                .foregroundColor(connectivityManager.isConnected ? .green : .red)
                .padding(.trailing, 5)
                .onChange(of: connectivityManager.isConnected) { newValue in
                    print("TopBarView: isConnected changed to \(newValue)")
                }

            // Profile picture button
            Button(action: {
                onProfileTap()
            }) {
                if connectivityManager.isConnected, let url = URL(string: profilePictureURL) {
                    AsyncImage(url: url) { image in
                        image
                            .resizable()
                            .frame(width: 40, height: 40)
                            .clipShape(Circle())
                    } placeholder: {
                        Image(systemName: "person.circle.fill")
                            .resizable()
                            .frame(width: 40, height: 40)
                            .clipShape(Circle())
                    }
                } else {
                    // Show initials or placeholder when offline
                    Circle()
                        .fill(Color.gray)
                        .frame(width: 40, height: 40)
                        .overlay(Text(getInitials(from: profilePictureURL))
                                    .font(.headline)
                                    .foregroundColor(.white))
                }
            }
        }
        .padding()
        .background(Color.white.opacity(0.99))
    }

    // Helper function to get initials
    func getInitials(from name: String) -> String {
        let nameComponents = name.components(separatedBy: " ")
        let initials = nameComponents.compactMap { $0.first }.prefix(2)
        return initials.map { String($0) }.joined()
    }
}

struct TopBarView_Previews: PreviewProvider {
    static var previews: some View {
        TopBarView(profilePictureURL: "https://example.com/profile_picture.jpg", connectivityManager: ConnectivityManager.shared) {
            // Preview action
        }
    }
}
