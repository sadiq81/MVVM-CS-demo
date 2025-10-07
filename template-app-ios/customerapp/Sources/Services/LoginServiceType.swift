import Foundation
import MustacheFoundation
import MustacheServices


protocol LoginServiceType {

    func login(username: String, password: String) async throws

    func forgotPassword(email: String) async throws

    func logOut() async throws
}

class LoginService: LoginServiceType {

    @Injected
    private var installationService: InstallationServiceType

    @Injected
    private var credentialsService: AsyncCredentialsServiceType

    @LazyInjected
    private var networkService: AsyncNetworkServiceType

    @LazyInjected
    private var userService: UserServiceType

    func login(username: String, password: String) async throws {

        //TODO: Handle missing installationId
        let appInstallationId = try await self.installationService.appInstallationId()
        let request = LoginRequest(username: username, password: password, installationId: appInstallationId)
        let response = try await self.networkService.login(request: request)
        let token = AuthToken(response: response)
        await self.credentialsService.setCredential(type: .oauth, value: token)

    }

    func forgotPassword(email: String) async throws {

        let appInstallationId = try await self.installationService.appInstallationId()
        let request = ResetPasswordRequest(email: email, installationId: appInstallationId)
        try await self.networkService.resetPassword(request: request)

    }

    func logOut() async throws {
        let appInstallationId = try await self.installationService.appInstallationId()
        let request = LogoutRequest(installationId: appInstallationId)
        _ = try? await self.networkService.logout(request: request)
        await self.credentialsService.setCredential(type: .oauth, value: nil)
        NotificationCenter.default.post(name: .logOut, object: nil)
    }

    deinit {
        debugPrint("deinit \(self)")
    }

}

extension AuthToken {
    
    init(response: LoginResponse) {
        self.init(accessToken: response.accessToken,
                  accessTokenExpiration: response.accessTokenExpiry,
                  refreshToken: response.refreshToken,
                  refreshTokenExpiration: response.refreshTokenExpiry)
    }
    
}
