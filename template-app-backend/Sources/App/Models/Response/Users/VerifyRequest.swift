
import Vapor

struct VerifyRequest: Content {

    var userinfoToken: String
    var idTokenHint: String

}

extension VerifyRequest: Validatable {
    static func validations(_ validations: inout Validations) {
        validations.add("userinfoToken", as: String.self, is: !.empty)
        validations.add("idTokenHint", as: String.self, is: !.empty)
    }
}
