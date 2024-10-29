import JWTDecode
import Foundation

struct Profile: Codable {  // Conformar a Codable
    let id: String
    let name: String
    let nickname: String
    let email: String
    let emailVerified: String
    let picture: String
    let updatedAt: String
}

extension Profile {
    static var empty: Self {
        return Profile(
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

        return Profile(
            id: id,
            name: name,
            nickname: nickname,
            email: email,
            emailVerified: String(describing: emailVerified),
            picture: picture,
            updatedAt: updatedAt
        )
    }
}
