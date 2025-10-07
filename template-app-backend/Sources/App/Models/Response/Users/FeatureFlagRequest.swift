import Vapor

struct FeatureFlagRequest: Content {
    
    let name: String
    let enabled: Bool
    
}

extension FeatureFlagRequest: Validatable {
    static func validations(_ validations: inout Validations) {
        validations.add("name", as: String.self, is: !.empty)
        validations.add("enabled", as: Bool.self)
    }
}
