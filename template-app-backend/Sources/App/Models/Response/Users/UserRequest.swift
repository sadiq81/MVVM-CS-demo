
import Vapor

struct UserRequest: Content {

    let firstName: String
    let lastName: String?
    let birthDate: Date?
    let phoneCountry: String?
    let phoneNumber: String?
    let email: String
    let street: String?
    let zipCode: String?
    let city: String?
    let country: String?

}

extension UserRequest: Validatable {
    static func validations(_ validations: inout Validations) {
        validations.add("firstName", as: String.self, is: !.empty)
        validations.add("email", as: String.self, is: .email)
    }
}
