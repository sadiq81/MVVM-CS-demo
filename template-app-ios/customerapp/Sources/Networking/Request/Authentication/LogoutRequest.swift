import Foundation
import MustacheFoundation

struct LogoutRequest: Codable {

    var installationId: UUID

    init(installationId: UUID) {
        self.installationId = installationId
    }

}
