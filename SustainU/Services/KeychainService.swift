//
//  KeychainService.swift
//  SustainU
//
//  Created by Duarte Mantilla Ernesto Jose on 29/10/24.
//

import Foundation
import KeychainAccess

struct KeychainService {
    static let keychain = Keychain(service: "com.yourapp.SustainU")

    static func saveToken(_ token: String) {
        keychain["token"] = token
        print("Token saved to Keychain: \(token)")
    }

    static func loadToken() -> String? {
        let token = keychain["token"]
        print("Token loaded from Keychain: \(String(describing: token))")
        return token
    }


    static func deleteToken() {
        keychain["token"] = nil
    }

    static func saveProfile(_ profile: UserProfile) {
        do {
            let data = try JSONEncoder().encode(profile)
            keychain["profile"] = data.base64EncodedString()
            print("Profile saved to Keychain")
        } catch {
            print("Error saving profile: \(error)")
        }
    }


    static func loadProfile() -> UserProfile? {
        do {
            if let profileString = keychain["profile"],
               let data = Data(base64Encoded: profileString) {
                let profile = try JSONDecoder().decode(UserProfile.self, from: data)
                print("Profile loaded from Keychain")
                return profile
            }
        } catch {
            print("Error loading profile: \(error)")
        }
        print("No profile found in Keychain")
        return nil
    }


    static func deleteProfile() {
        keychain["profile"] = nil
    }
}
