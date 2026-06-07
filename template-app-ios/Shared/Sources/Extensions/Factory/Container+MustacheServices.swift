import Foundation

import MustacheCombine
import MustacheFoundation
import MustacheServices

enum AppContainer {

    static func configure() {

        // MARK: Network
        // Register refresh token service: link to shared asyncNetworkService instance
        Container.shared.refreshTokenService.register {
            Container.shared.asyncNetworkService() as? any RefreshTokenServiceType
        }

        // MARK: Overrides
        Container.shared.secureStorageMaxPinAttempts.register { 3 }

    }
}
