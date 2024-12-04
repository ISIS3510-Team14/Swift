    //
    //  UserProfile.swift
    //  SustainU
    //
    //  Created by Duarte Mantilla Ernesto Jose on 29/10/24.
    //

    import JWTDecode
    import Foundation

    struct UserProfile: Codable {
        let id: String
        let name: String
        let nickname: String
        let email: String
        let emailVerified: String
        let picture: String
        let updatedAt: String
        
        var career: String?
        var semester: String?
    }

    extension UserProfile {
        static var empty: Self {
            return UserProfile(
                id: "",
                name: "",
                nickname: "",
                email: "",
                emailVerified: "",
                picture: "",
                updatedAt: ""
            )
        }

        static func from(_ idToken: String) -> Self {
            guard
                let jwt = try? decode(jwt: idToken),
                let id = jwt.subject,
                let name = jwt.claim(name: "name").string,
                let email = jwt.claim(name: "email").string,
                let emailVerified = jwt.claim(name: "email_verified").boolean,
                let picture = jwt.claim(name: "picture").string,
                let updatedAt = jwt.claim(name: "updated_at").string,
                let nickname = jwt.claim(name: "nickname").string
            else {
                return .empty
            }

            return UserProfile(
                id: id,
                name: name,
                nickname: nickname,
                email: email,
                emailVerified: String(describing: emailVerified),
                picture: picture,
                updatedAt: updatedAt
            )
        }

        static func from(_ profileInfo: [String: Any]) -> Self {
            return UserProfile(
                id: profileInfo["user_id"] as? String ?? "",
                name: profileInfo["name"] as? String ?? "",
                nickname: profileInfo["nickname"] as? String ?? "",
                email: profileInfo["email"] as? String ?? "",
                emailVerified: String(describing: profileInfo["email_verified"] as? Bool ?? false),
                picture: profileInfo["picture"] as? String ?? "",
                updatedAt: profileInfo["updated_at"] as? String ?? ""
            )
        }
    }
