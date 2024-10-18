import SwiftUI

struct TopBarView: View {
    var profilePictureURL: String

    var body: some View {
        HStack {
            Image("logoBigger")
                .resizable()
                .scaledToFit()
                .frame(width: 50, height: 50)
                .clipShape(Circle())

            Spacer()
            
            AsyncImage(url: URL(string: profilePictureURL)) { image in
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
        }
        .padding()
        .background(Color.white.opacity(0.99))
    }
}

struct TopBarView_Previews: PreviewProvider {
    static var previews: some View {
        TopBarView(profilePictureURL: "https://example.com/profile_picture.jpg")
    }
}

