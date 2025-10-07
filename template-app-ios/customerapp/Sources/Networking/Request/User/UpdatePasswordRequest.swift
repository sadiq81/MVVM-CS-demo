
struct UpdatePasswordRequest: Encodable {
    let oldPassword: String
    let password: String
    let repeatPassword: String
    
    enum CodingKeys: String, CodingKey {
        case oldPassword = "currentPassword"
        case password = "newPassword"
        case repeatPassword = "confirmPassword"
    }
}
