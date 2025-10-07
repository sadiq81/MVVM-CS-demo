
import MustacheFoundation
import MustacheServices
import MustacheCombine

protocol InstallationServiceType {

    var installationId: UUID? { get }

    func appInstallationId() async throws -> UUID

}

class InstallationService: InstallationServiceType {

    // Used for identifiying individual devices
    @StorageCombine("InstallationService.installationId", mode: .keychain(accessibility: .afterFirstUnlockThisDeviceOnly))
    var installationId: UUID?

    @LazyInjected
    private var networkService: AsyncNetworkServiceType

    func appInstallationId() async throws -> UUID {
        if let installationId = self.installationId {
            return installationId
        } else {
            let request = InstallationRequest()
            let response: InstallationResponse = try await self.networkService.installation(request: request)
            self.installationId = response.id
            return response.id
        }
    }

}
