import SwiftUI
import Firebase
import FirebaseFirestore
import Auth0

struct ProfileView: View {
    var userProfile: UserProfile

    @ObservedObject private var viewModel = LoginViewModel.shared
    @Environment(\.presentationMode) var presentationMode
    @State private var career: String = ""
    @State private var semester: String = ""
    @State private var showAlert: Bool = false // Estado para controlar la alerta


    // Referencia a Firestore
    private var db = Firestore.firestore()

    
    init(userProfile: UserProfile) {
            self.userProfile = userProfile
        }
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
                // Show the image if connected
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
                // Show initials if not connected
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

            // User's nickname
            Text(viewModel.userProfile.nickname)
                .font(.title2)
                .fontWeight(.bold)
                .padding(.top)

            // User's email
            Text("Email: \(viewModel.userProfile.email)")
                .font(.subheadline)
                .foregroundColor(.gray)
                .padding(.top, 2)

            // Career input field
            TextField("Enter your career", text: $career)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.top, 20)
                .onAppear {
                    // Pre-fill career if available
                    self.career = viewModel.userProfile.career ?? ""
                }

            // Semester input field
            TextField("Enter your semester", text: $semester)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.top, 20)
                .onAppear {
                    // Pre-fill semester if available
                    self.semester = viewModel.userProfile.semester ?? ""
                }

            // Save button
            Button(action: {
                saveProfile()
            }) {
                HStack {
                    Image(systemName: "square.and.arrow.down.fill")
                        .font(.title2)
                    Text("Save Profile")
                        .font(.headline)
                        .fontWeight(.bold)
                }
                .foregroundColor(.white)
                .padding()
                .frame(width: 220, height: 50)
                .background(Color.green)
                .cornerRadius(25)
            }
            .padding(.top, 30)

            // Logout button
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
    }

    // Function to save the profile data to Firestore
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
