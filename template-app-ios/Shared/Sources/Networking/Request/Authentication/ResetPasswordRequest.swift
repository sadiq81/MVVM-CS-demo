import Foundation

struct ResetPasswordRequest: Encodable {
    let email: String
    let installationId: UUID
}
