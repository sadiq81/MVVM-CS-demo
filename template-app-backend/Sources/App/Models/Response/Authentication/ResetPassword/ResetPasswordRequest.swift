import Vapor

struct ResetPasswordRequest: Content {
    let email: String
    let installationId: UUID
}

extension ResetPasswordRequest: Validatable {
    static func validations(_ validations: inout Validations) {
        validations.add("email", as: String.self, is: .email)
    }
}
