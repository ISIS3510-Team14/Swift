import SwiftUI

struct RecycleView: View {
    @ObservedObject private var connectivityManager = ConnectivityManager.shared
    var userProfile: UserProfile // Asume que estás pasando el perfil del usuario desde `HomeView` o el lugar donde instancies `RecycleView`
    
    var body: some View {
        VStack {
            // Agrega TopBarView en la parte superior
            TopBarView(profilePictureURL: userProfile.picture, connectivityManager: connectivityManager) {
                print("Profile tapped")
            }
            .padding(.top, 30) // Añade un padding para separarlo del borde superior en dispositivos con notch
            
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("Residues:")
                        .font(.title)
                        .fontWeight(.bold)
                        .padding(.leading)
                    
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 20) {
                        NavigationLink(destination: RecycleDetailView(
                            title: "Paper",
                            iconName: "paper_icon",
                            fact: "Recycling one ton of paper saves 17 trees",
                            trashCanImageName: "gray_trash_can",
                            disposalInfo: "Paper is most of the time thrown in the gray trash can",
                            extraInfo: "If you can you might want to remove any contaminants like plastic windows from envelopes before recycling."
                        )) {
                            RecycleCardView(title: "Paper", iconName: "paper_icon", description: "Boxes, magazines, notepads")
                        }
                        
                        NavigationLink(destination: RecycleDetailView(
                            title: "Plastic",
                            iconName: "plastic_icon",
                            fact: "Plastics take up to 500 years to decompose.",
                            trashCanImageName: "blue_trash_can",
                            disposalInfo: "Plastic is most of the time thrown in the blue trash can",
                            extraInfo: "Not all plastics are recyclable—check for symbols like 1 (PET) and 2 (HDPE)."
                        )) {
                            RecycleCardView(title: "Plastic", iconName: "plastic_icon", description: "Packages, PET, bottles")
                        }
                        
                        NavigationLink(destination: RecycleDetailView(
                            title: "Glass",
                            iconName: "glass_icon",
                            fact: "Glass can be endlessly recycled without losing quality.",
                            trashCanImageName: "blue_trash_can",
                            disposalInfo: "Glass is most of the time thrown in the blue trash can",
                            extraInfo: "If you can, separate colored glass, as mixing them can reduce recyclability."
                        )) {
                            RecycleCardView(title: "Glass", iconName: "glass_icon", description: "Bottles, containers")
                        }
                        
                        NavigationLink(destination: RecycleDetailView(
                            title: "Metal",
                            iconName: "metal_icon",
                            fact: "Recycling aluminum saves 95% of the energy used to produce new metal.",
                            trashCanImageName: "blue_trash_can",
                            disposalInfo: "Metal is most of the time thrown in the blue trash can",
                            extraInfo: "You might want to ensure metals are clean of food residue before recycling."
                        )) {
                            RecycleCardView(title: "Metal", iconName: "metal_icon", description: "Cans, utensils")
                        }
                    }
                    .padding(.horizontal)
                    
                    if connectivityManager.isConnected {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("More Information:")
                                .font(.headline)
                            
                            Link("How to Recycle - How2Recycle", destination: URL(string: "https://how2recycle.info/")!)
                                .foregroundColor(.blue)
                            Link("EPA: How to Recycle Common Recyclables", destination: URL(string: "https://www.epa.gov/recycle/how-do-i-recycle-common-recyclables")!)
                                .foregroundColor(.blue)
                            Link("Earth Day: 7 Tips to Recycle Better", destination: URL(string: "https://www.earthday.org/7-tips-to-recycle-better/")!)
                                .foregroundColor(.blue)
                        }
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(10)
                        .padding(.horizontal)
                    }
                }
                .padding(.top) // Espacio superior adicional para contenido
                .padding(.bottom) // Opcional: espacio inferior adicional
            }
        }
        .edgesIgnoringSafeArea(.top) // Ignora el área segura en la parte superior para que el TopBarView se vea correctamente
    }
}
