import MustacheFoundation
import UIKit

struct InstallationRequest: Codable {

    var modelIdentifier: String
    var identifierForVendor: String

    init(modelIdentifier: String = UIDevice.current.modelIdentifier ?? "",
         identifierForVendor: String = "\(UIDevice.current.identifierForVendor?.uuidString ?? "")") {
        self.modelIdentifier = modelIdentifier
        self.identifierForVendor = identifierForVendor
    }

    enum CodingKeys: String, CodingKey {
        case modelIdentifier = "deviceModel"
        case identifierForVendor
    }

}
