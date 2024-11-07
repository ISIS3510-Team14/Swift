import SwiftUI

struct SavedImagesView: View {
    @State private var savedImages: [CameraViewmodel.SavedImage] = []
    private let viewModel = CameraViewmodel()
    @Binding var selectedImage: UIImage? // Añadir selectedImage como Binding para actualizar CameraView
    @Binding var selectedTab: Int // Añade selectedTab como Binding
    @Environment(\.presentationMode) var presentationMode // Controla la presentación del sheet

    var body: some View {
        VStack {
            Text("Temporary Images")
                .font(.title)
                .fontWeight(.bold)
                .padding()

            List {
                ForEach(savedImages.indices, id: \.self) { index in
                    let savedImage = savedImages[index]
                    HStack {
                        if let uiImage = loadImage(fileName: savedImage.fileName) {
                            Button(action: {
                                selectedImage = uiImage // Asigna la imagen seleccionada
                                selectedTab = 2
                                viewModel.deleteImageWithMetadata(fileName: savedImage.fileName) // Elimina la imagen y su metadata
                                savedImages.remove(at: index) // Actualiza la lista en la vista
                                presentationMode.wrappedValue.dismiss() // Cierra el sheet
                            }) {
                                Image(uiImage: uiImage)
                                    .resizable()
                                    .frame(width: 50, height: 50)
                                    .cornerRadius(5)
                            }
                        }
                        VStack(alignment: .leading) {
                            Text("Image \(index + 1)")
                                .font(.headline)
                            Text(savedImage.date, style: .date)
                                .font(.subheadline)
                        }
                    }
                    .padding(.vertical, 8)
                }
            }
            .onAppear {
                savedImages = viewModel.loadSavedImages()
            }
        }
        .navigationTitle("Temporary Images")
    }

    private func loadImage(fileName: String) -> UIImage? {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let fileURL = documentsDirectory.appendingPathComponent(fileName)
        return UIImage(contentsOfFile: fileURL.path)
    }
    
    private func deleteImageAndRemoveFromList(at index: Int, fileName: String) {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let fileURL = documentsDirectory.appendingPathComponent(fileName)
        
        do {
            try FileManager.default.removeItem(at: fileURL)
            print("Imagen eliminada: \(fileURL.path)")
            savedImages.remove(at: index) // Remueve la imagen de la lista
        } catch {
            print("Error al eliminar la imagen: \(error.localizedDescription)")
        }
        
    }
}
