#if DEBUG

import Foundation

final class PreviewInstallationService: InstallationServiceType, @unchecked Sendable {

    var installationId: UUID? = UUID(uuidString: "12345678-1234-1234-1234-123456789ABC")

    func appInstallationId() async throws -> UUID {
        return self.installationId ?? UUID()
    }

}

#endif
