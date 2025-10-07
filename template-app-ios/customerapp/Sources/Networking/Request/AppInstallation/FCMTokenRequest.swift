import Foundation

struct FCMTokenRequest: Encodable {
    var token: String?
    var installationId: UUID

    enum CodingKeys: String, CodingKey {
        case token
    }
}
