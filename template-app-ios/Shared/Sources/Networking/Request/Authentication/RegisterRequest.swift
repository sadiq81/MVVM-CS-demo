import Foundation

struct RegisterRequest: Encodable {
    let firstName: String
    let email: String
    let password: String
    let confirmPassword: String
}
