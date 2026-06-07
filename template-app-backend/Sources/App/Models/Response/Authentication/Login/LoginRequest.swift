import Vapor

struct LoginRequest: Content {
    let email: String
    let password: String
    let installationId: UUID
}

extension LoginRequest: Validatable {
    static func validations(_ validations: inout Validations) {
        validations.add("email", as: String.self, is: .email)
        validations.add("password", as: String.self, is: !.empty)
        validations.add("installationId", as: String.self, is: !.empty)
    }
}
