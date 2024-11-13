import SwiftUI

struct CollectionPointDetailView: View {
    let point: CollectionPoint
    @StateObject private var imageLoader = ImageLoader()
    
    
    private func getRecycleDetailView(for material: String) -> RecycleDetailView {
        if let config = RecycleTypes.configurations[material] {
            return RecycleDetailView(
                title: config.title,
                iconName: config.iconName,
                fact: config.fact,
                trashCanImageName: config.trashCanImageName,
                disposalInfo: config.disposalInfo,
                extraInfo: config.extraInfo
            )
        } else {
            // Caso default
            return RecycleDetailView(
                title: material,
                iconName: "recycle_icon",
                fact: "This material is recyclable",
                trashCanImageName: "blue_trash_can",
                disposalInfo: "Please check local recycling guidelines",
                extraInfo: "When in doubt, consult your local recycling center"
            )
        }
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // Image with cache
                Group {
                    if let uiImage = imageLoader.image {
                        Image(uiImage: uiImage)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(height: 200)
                            .cornerRadius(12)
                            .padding(.horizontal)
                    } else {
                        AsyncImage(url: URL(string: point.imageName)) { phase in
                            switch phase {
                            case .success(let image):
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(height: 200)
                                    .cornerRadius(12)
                                    .padding(.horizontal)
                            case .failure(_):
                                Image(systemName: "photo")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(height: 200)
                                    .cornerRadius(12)
                                    .padding(.horizontal)
                                    .foregroundColor(.gray)
                            case .empty:
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle())
                                    .scaleEffect(2)
                                    .frame(height: 200)
                                    .padding(.horizontal)
                            @unknown default:
                                EmptyView()
                            }
                        }
                    }
                }
                
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
                                    ForEach(point.info3, id: \.self) { material in
                                        NavigationLink(destination: getRecycleDetailView(for: material)) {
                                            Text(material)
                                                .font(.body)
                                                .foregroundColor(Color("blueLogoColor"))
                                        }
                                    }
                                }
                                .padding(.horizontal)
                
                Spacer()
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading: CustomBackButton())
        .onAppear {
            imageLoader.loadImage(from: point.imageName)
        }
    }
}

// Image Loader class to handle caching
class ImageLoader: ObservableObject {
    @Published var image: UIImage?
    private let cache = NSCache<NSString, UIImage>()
    private let fileManager = FileManager.default
    
    func loadImage(from urlString: String) {
        let cacheKey = NSString(string: urlString)
        
        // First, check memory cache
        if let cachedImage = cache.object(forKey: cacheKey) {
            self.image = cachedImage
            return
        }
        
        // Then, check disk cache
        if let diskCachedImage = loadImageFromDisk(for: urlString) {
            self.image = diskCachedImage
            // Store in memory cache
            cache.setObject(diskCachedImage, forKey: cacheKey)
            return
        }
        
        // If not in cache, download the image
        guard let url = URL(string: urlString) else { return }
        
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            guard let self = self,
                  let data = data,
                  let downloadedImage = UIImage(data: data) else {
                return
            }
            
            DispatchQueue.main.async {
                // Save to memory cache
                self.cache.setObject(downloadedImage, forKey: cacheKey)
                // Save to disk cache
                self.saveImageToDisk(downloadedImage, for: urlString)
                self.image = downloadedImage
            }
        }.resume()
    }
    
    private func saveImageToDisk(_ image: UIImage, for urlString: String) {
        guard let data = image.jpegData(compressionQuality: 0.8),
              let cacheDirectory = try? FileManager.default.url(for: .cachesDirectory,
                                                              in: .userDomainMask,
                                                              appropriateFor: nil,
                                                              create: true) else {
            return
        }
        
        let fileName = urlString.replacingOccurrences(of: "/", with: "_")
        let fileURL = cacheDirectory.appendingPathComponent(fileName)
        
        try? data.write(to: fileURL)
    }
    
    private func loadImageFromDisk(for urlString: String) -> UIImage? {
        guard let cacheDirectory = try? FileManager.default.url(for: .cachesDirectory,
                                                              in: .userDomainMask,
                                                              appropriateFor: nil,
                                                              create: false) else {
            return nil
        }
        
        let fileName = urlString.replacingOccurrences(of: "/", with: "_")
        let fileURL = cacheDirectory.appendingPathComponent(fileName)
        
        guard let data = try? Data(contentsOf: fileURL),
              let image = UIImage(data: data) else {
            return nil
        }
        
        return image
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
