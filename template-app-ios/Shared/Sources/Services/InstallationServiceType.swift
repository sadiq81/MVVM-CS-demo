import Foundation

import MustacheCombine
import MustacheFoundation
import MustacheServices

protocol InstallationServiceType: Sendable {

    var installationId: UUID? { get }

    func appInstallationId() async throws -> UUID

}

final class InstallationService: InstallationServiceType, @unchecked Sendable {

    // Used for identifiying individual devices
    @StorageCombine("InstallationService.installationId", mode: .keychain(accessibility: .afterFirstUnlockThisDeviceOnly))
    var installationId: UUID?

    @LazyInjected(\.asyncNetworkService)
    private var networkService: any AsyncNetworkServiceType

    func appInstallationId() async throws -> UUID {
        if let installationId = self.installationId {
            return installationId
        } else {
            let request = await InstallationRequest()
            let response: InstallationResponse = try await self.networkService.installation(request: request)
            await MainActor.run { self.installationId = response.id }
            return response.id
        }
    }

}
