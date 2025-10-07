import Vapor

struct UpdatePasswordRequest: Content {
    let currentPassword: String
    let newPassword: String
    let confirmPassword: String
}

extension UpdatePasswordRequest: Validatable {
    static func validations(_ validations: inout Validations) {
        validations.add("currentPassword", as: String.self, is: !.empty)
        validations.add("newPassword", as: String.self, is: .count(8...))
        validations.add("confirmPassword", as: String.self, is: !.empty)
    }
}
