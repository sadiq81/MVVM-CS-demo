
import Vapor

struct LogoutRequest: Content {
    let installationId: UUID
    
}

extension LogoutRequest: Validatable {
    static func validations(_ validations: inout Validations) {
        validations.add("installationId", as: String.self, is: !.empty)
    }
}
