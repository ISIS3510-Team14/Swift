import SwiftUI

struct CollectionPointDetailView: View {
    let point: CollectionPoint
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // Image
                Image("recycling_bins") // Replace with actual image or use a placeholder
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 200)
                    .cornerRadius(12)
                
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
                    Text("Materials Accepted:")
                        .font(.headline)
                    
                    ForEach(point.materials.components(separatedBy: ", "), id: \.self) { material in
                        HStack(spacing: 8) {
                            Image(systemName: "circle.fill")
                                .foregroundColor(.green)
                                .font(.system(size: 8))
                            Text(material)
                                .font(.body)
                        }
                    }
                }
                .padding(.horizontal)
                
                Spacer()
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}

// Preview
struct CollectionPointDetailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            CollectionPointDetailView(point: CollectionPoint(
                name: "Mario Laserna Building",
                location: "5th floor - Near cafeteria",
                materials: "Disposables, Non disposables, Organic",
                latitude: 4.602547,
                longitude: -74.06            ))
        }
    }
}
