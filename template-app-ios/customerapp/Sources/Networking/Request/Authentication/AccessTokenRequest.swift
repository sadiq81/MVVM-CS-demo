import Foundation

struct AccessTokenRequest: Encodable {
    let refreshToken: String
    var installationId: UUID
}
