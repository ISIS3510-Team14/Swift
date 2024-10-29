import Foundation
import KeychainAccess

struct KeychainService {
    static let keychain = Keychain(service: "com.yourapp.SustainU")

    static func saveToken(_ token: String) {
        keychain["token"] = token
    }
    
    static func loadToken() -> String? {
        return keychain["token"]
    }
    
    static func deleteToken() {
        keychain["token"] = nil
    }
    
    static func saveProfile(_ profile: Profile) {
        if let data = try? JSONEncoder().encode(profile) {
            keychain["profile"] = data.base64EncodedString()
        }
    }
    
    static func loadProfile() -> Profile? {
        if let profileString = keychain["profile"],
           let data = Data(base64Encoded: profileString),
           let profile = try? JSONDecoder().decode(Profile.self, from: data) {
            return profile
        }
        return nil
    }
    
    static func deleteProfile() {
        keychain["profile"] = nil
    }
}
