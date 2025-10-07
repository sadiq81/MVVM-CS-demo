
import Foundation
import Vapor

struct InstallationRequest: Content {
    
    let deviceModel: String
    let identifierForVendor: String?
    
}

extension InstallationRequest: Validatable {
    
    static func validations(_ validations: inout Validations) {
        validations.add("deviceModel", as: String.self, is: !.empty)
    }
    
}

extension Installation {
    convenience init(from request: InstallationRequest) {
        self.init(deviceModel: request.deviceModel,
                  identifierForVendor: request.identifierForVendor)
    }
}
