import Foundation

struct RegisterRequest: Encodable {
    let fullName: String
    let email: String
    let password: String
    let confirmPassword: String
}
