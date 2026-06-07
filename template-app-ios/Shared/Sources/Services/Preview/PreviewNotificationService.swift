#if DEBUG

import Foundation

final class PreviewNotificationService: NotificationServiceType, @unchecked Sendable {

    func received(deviceToken: Data) {
        // no-op
    }

    func register() {
        // no-op
    }

}

#endif
