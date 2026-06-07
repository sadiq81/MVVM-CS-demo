#if DEBUG

import Foundation

final class PreviewLoggingService: LoggingServiceType, @unchecked Sendable {

    func log(event: LoggingEvent) {
        // no-op
    }

}

#endif
