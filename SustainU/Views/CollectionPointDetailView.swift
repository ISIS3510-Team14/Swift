import SwiftUI

struct CollectionPointDetailView: View {
    let point: CollectionPoint
   
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // Image
                Image(point.imageName) // Replace with actual image or use a placeholder
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 200)
                    .cornerRadius(12)
                    .padding(.horizontal)
               
                // Name and Location
                VStack(alignment: .leading, spacing: 8) {
                    Text(point.name)
                        .font(.title2)
                        .fontWeight(.bold)
                   
                    Text(point.location)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal)
               
                // Materials
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(point.materials.components(separatedBy: ", "), id: \.self) { material in
                        Text(material)
                            .font(.body)
                            .foregroundColor(Color("blueLogoColor"))
                    }
                }
                .padding(.horizontal)
               
                Spacer()
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading: CustomBackButton())
    }
}

struct CustomBackButton: View {
    @Environment(\.presentationMode) var presentationMode
   
    var body: some View {
        Button(action: {
            self.presentationMode.wrappedValue.dismiss()
        }) {
            Image(systemName: "chevron.left")
                .foregroundColor(Color("greenLogoColor"))
        }
    }
}


