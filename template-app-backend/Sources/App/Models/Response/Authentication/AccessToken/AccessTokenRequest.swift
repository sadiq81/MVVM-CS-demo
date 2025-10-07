import Vapor

struct AccessTokenRequest: Content {
    let refreshToken: String
    let installationId: UUID
}
