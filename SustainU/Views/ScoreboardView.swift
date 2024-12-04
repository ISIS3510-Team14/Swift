import SwiftUI
import Firebase
import Combine

struct ScoreboardView: View {
    @State private var users: [User] = []
    @State private var searchText = ""
    let profilePictureURL: String
    @State private var showOfflinePopup = false // Estado del popup
    @StateObject private var connectivityManager = ConnectivityManager.shared


    struct User: Identifiable {
        let id: String
        let name: String
        let totalPoints: Int
        let streak: Int
        let profilePictureURL: String
    }

    var body: some View {
        
        VStack {
            TopBarView(profilePictureURL: profilePictureURL, connectivityManager: ConnectivityManager.shared)
            
            ZStack {
                
                VStack {
                    Text("Scoreboard")
                        .font(.largeTitle)
                        .bold()
                        .padding(.top, 5)
                    
                    // Barra de búsqueda estilizada
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.gray)
                        TextField("Search", text: $searchText)
                            .textFieldStyle(PlainTextFieldStyle())
                            .padding(.leading, 8)
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                    .padding(.horizontal)
                        
                    // Listado de usuarios
                    ScrollView {
                        ForEach(filteredUsers, id: \.id) { user in
                            HStack {
                                CachedAsyncImage(url: user.profilePictureURL, cacheKey: user.id)
                                    .frame(width: 50, height: 50)
                                    .clipShape(Circle())
                                
                                VStack(alignment: .leading) {
                                    Text(user.name)
                                        .font(.headline)
                                    Text("\(user.streak) Days")
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                }

                                Spacer()

                                Text("\(user.totalPoints) Points")
                                    .font(.headline)
                                    .foregroundColor(Color("greenLogoColor"))
                            }
                            .padding()
                        }
                    }
                }
    
                // Popup Offline
                OfflineScoreboardPopupView(isPresented: $showOfflinePopup)
            }
        }
        .onAppear {
            checkConnectivity()
            loadUsers()
        }
        .onChange(of: connectivityManager.isConnected) { newValue in
            if !newValue {
                showOfflinePopup = true
            }
        }
    }

    // Filtrar usuarios según la barra de búsqueda
    private var filteredUsers: [User] {
        if searchText.isEmpty {
            return users
        } else {
            return users.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
        }
    }
    
    func calculateStreak(from history: [[String: Any]]) -> Int {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let sortedDates = history.compactMap { $0["date"] as? String }
            .compactMap { dateFormatter.date(from: $0) }
            .sorted(by: >) // Ordenar de la fecha más reciente a la más antigua
        
        guard !sortedDates.isEmpty else {
            print("No hay fechas en el historial")
            return 0
        }
        
        // Calcular la racha
        var streak = 1 // Al menos un día si hay fechas
        var currentDate = sortedDates.first! // Fecha más reciente
        let calendar = Calendar.current
        
        for date in sortedDates.dropFirst() { // Omitimos la primera ya que es la más reciente
            let difference = calendar.dateComponents([.day], from: date, to: currentDate).day ?? 0
            
            if difference == 1 { // Días consecutivos
                streak += 1
                currentDate = date
            } else if difference > 1 { // Si no son consecutivos, termina la racha
                break
            }
        }
        
        print("Racha calculada: \(streak)")
        return streak
    }


    // Función para cargar usuarios desde Firestore
    private func loadUsers() {
        let db = Firestore.firestore()
        db.collection("users").getDocuments { snapshot, error in
            guard let documents = snapshot?.documents else {
                print("Error fetching documents: \(error?.localizedDescription ?? "Unknown error")")
                return
            }

            var loadedUsers: [User] = []
            for document in documents {
                let data = document.data()
                guard let email = data["user_id"] as? String else { continue }

                let name = email.components(separatedBy: "@").first ?? "Unknown"
                let points = data["points"] as? [String: Any]
                let total = points?["total"] as? Int ?? 0
                let history = points?["history"] as? [[String: Any]] ?? []
                print("history in loadUsers(): ", history)
                let streak = calculateStreak(from: history)
                let profileURL = "https://picsum.photos/seed/\(name)/100"
                let user = User(id: email, name: name, totalPoints: total, streak: streak, profilePictureURL: profileURL)
                loadedUsers.append(user)
            }

            // Ordenar por puntos
            loadedUsers.sort(by: { $0.totalPoints > $1.totalPoints })
            self.users = loadedUsers
        }
    }
    
    private func checkConnectivity() {
        if !connectivityManager.isConnected {
            showOfflinePopup = true
        }
    }
}



class ImageCacheManager {
    static let shared = ImageCacheManager()
    private let cache = NSCache<NSString, UIImage>()
    private let fileManager = FileManager.default
    private let cacheDirectory: URL

    private init() {
        cacheDirectory = fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first!
    }

    func getImage(for key: String) -> UIImage? {
        // Buscar en la memoria
        if let cachedImage = cache.object(forKey: key as NSString) {
            //print("CACHEEE")
            return cachedImage
        }

        return nil
    }

    func saveImage(_ image: UIImage, for key: String) {
        // Guardar en la memoria
        cache.setObject(image, forKey: key as NSString)


    }
}


struct CachedAsyncImage: View {
    let url: String
    let cacheKey: String
    @State private var image: UIImage?
    @StateObject private var connectivityManager = ConnectivityManager.shared


    var body: some View {
        Group {
            if let image = image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
            } else {
                ProgressView()
                    .onAppear {
                        loadImage()
                    }
            }
        }
    }

    private func loadImage() {
        if let cachedImage = ImageCacheManager.shared.getImage(for: cacheKey) {
            self.image = cachedImage
        } else if connectivityManager.isConnected {
            downloadImage()
        } else { // ayudaa
            self.image = UIImage(named: "pp")
        }
    }

    private func downloadImage() {
        guard let url = URL(string: url) else { return }
        URLSession.shared.dataTask(with: url) { data, _, _ in
            if let data = data, let downloadedImage = UIImage(data: data) {
                DispatchQueue.main.async {
                    self.image = downloadedImage
                    ImageCacheManager.shared.saveImage(downloadedImage, for: cacheKey)
                }
            }
        }.resume()
    }
}
