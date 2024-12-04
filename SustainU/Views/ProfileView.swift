import SwiftUI
import Firebase
import Auth0


struct ProfileView: View {
    var userProfile: UserProfile
    @ObservedObject private var viewModel = LoginViewModel.shared
    @Environment(\.presentationMode) var presentationMode
    @State private var career: String = ""
    @State private var semester: String = ""
    @State private var showAlert: Bool = false
    @State private var isDataLoaded: Bool = false // Estado para saber si los datos ya están cargados
    // Reference to Firestore
    let db = Firestore.firestore()

    var body: some View {
        VStack {
            // Back button in the top-left corner
            HStack {
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Image(systemName: "arrow.backward")
                        .font(.title)
                        .foregroundColor(Color.green)
                }
                Spacer()
            }
            .padding(.leading, 20)
            .padding(.top, 10)

            Spacer()
                .frame(height: 40)

            if let url = URL(string: viewModel.userProfile.picture), ConnectivityManager.shared.isConnected {
                AsyncImage(url: url) { image in
                    image
                        .resizable()
                        .scaledToFit()
                        .frame(width: 120, height: 120)
                        .clipShape(Circle())
                        .padding()
                } placeholder: {
                    Circle()
                        .fill(Color.red)
                        .frame(width: 120, height: 120)
                        .overlay(Text(viewModel.userProfile.name.prefix(1))
                                    .font(.largeTitle)
                                    .foregroundColor(.white))
                        .padding()
                }
            } else {
                Circle()
                    .fill(Color.red)
                    .frame(width: 120, height: 120)
                    .overlay(Text(viewModel.userProfile.name.prefix(1))
                                .font(.largeTitle)
                                .foregroundColor(.white))
                    .padding()
            }

            Spacer()
                .frame(height: 20)

            Text(viewModel.userProfile.nickname)
                .font(.title2)
                .fontWeight(.bold)
                .padding(.top)

            Text("Email: \(viewModel.userProfile.email)")
                .font(.subheadline)
                .foregroundColor(.gray)
                .padding(.top, 2)

            // Form to edit career and semester
            TextField("Enter Career", text: $career)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.top)
                .padding(.horizontal)

            TextField("Enter Semester", text: $semester)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.top)
                .padding(.horizontal)

            Button(action: {
                saveProfile()
            }) {
                Text("Save Profile")
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.green)
                    .cornerRadius(10)
                    .padding(.top)
            }

            Button(action: {
                logout()
            }) {
                HStack {
                    Image(systemName: "arrow.right.square.fill")
                        .font(.title2)
                    Text("Logout")
                        .font(.headline)
                        .fontWeight(.bold)
                }
                .foregroundColor(.white)
                .padding()
                .frame(width: 220, height: 50)
                .background(Color.red)
                .cornerRadius(25)
            }
            .padding(.bottom, 40)
        }
        .padding()
        .background(Color.white)
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text("Profile Saved"),
                message: Text("Your profile has been updated successfully!"),
                dismissButton: .default(Text("OK"))
            )
        }
        .onAppear {
            loadProfileData()
        }
    }

    func loadProfileData() {
        // Check if data exists in UserDefaults first
        if let savedCareer = UserDefaults.standard.string(forKey: "career"),
           let savedSemester = UserDefaults.standard.string(forKey: "semester") {
            career = savedCareer
            semester = savedSemester
        } else {
            // If no data in UserDefaults, load from Firebase
            fetchProfileFromFirebase()
        }
    }

    func fetchProfileFromFirebase() {
        guard !viewModel.userProfile.email.isEmpty else {
            print("Email is empty")
            return
        }

        let usersInfoRef = db.collection("users_info").document(viewModel.userProfile.email)
        usersInfoRef.getDocument { (document, error) in
            if let error = error {
                print("Error getting document: \(error)")
                return
            }

            if let document = document, document.exists {
                if let data = document.data() {
                    self.career = data["career"] as? String ?? ""
                    self.semester = data["semester"] as? String ?? ""
                    // Save fetched data to UserDefaults for persistence
                    UserDefaults.standard.set(self.career, forKey: "career")
                    UserDefaults.standard.set(self.semester, forKey: "semester")
                    self.isDataLoaded = true
                }
            } else {
                print("No profile data found in Firebase")
            }
        }
    }


    func saveProfile() {
        guard !viewModel.userProfile.email.isEmpty else {
            print("Email is required")
            return
        }

        // Reference to Firestore
        let usersInfoRef = db.collection("users_info").document(viewModel.userProfile.email)

        // Update the document with career and semester
        usersInfoRef.setData([
            "career": career,
            "semester": semester
        ], merge: true) { error in
            if let error = error {
                print("Error updating profile: \(error)")
            } else {
                print("Profile updated successfully")
                // Save data to UserDefaults for persistence
                UserDefaults.standard.set(self.career, forKey: "career")
                UserDefaults.standard.set(self.semester, forKey: "semester")
                // Show the alert after successful save
                showAlert = true
            }
        }
    }

    func logout() {
        if ConnectivityManager.shared.isConnected {
            // Online logout via Auth0
            Auth0
                .webAuth()
                .clearSession(federated: false) { result in
                    switch result {
                    case .success:
                        DispatchQueue.main.async {
                            self.viewModel.clearLocalSession()
                            self.presentationMode.wrappedValue.dismiss()
                        }
                        print("User logged out")
                    case .failure(let error):
                        print("Failed with: \(error)")
                    }
                }
        } else {
            // Offline logout
            viewModel.clearLocalSession()
            DispatchQueue.main.async {
                self.presentationMode.wrappedValue.dismiss()
            }
            print("Logged out locally without internet connection")
        }
    }
}
