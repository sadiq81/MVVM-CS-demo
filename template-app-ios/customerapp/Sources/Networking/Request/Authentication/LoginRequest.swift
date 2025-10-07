import Foundation
import MustacheFoundation

struct LoginRequest: Codable {

    var username: String
    var password: String
    var installationId: UUID

    init(username: String, password: String, installationId: UUID) {
        self.username = username
        self.password = password
        self.installationId = installationId
    }

    enum CodingKeys: String, CodingKey {
        case username = "email"
        case password
        case installationId
    }
}
