import Foundation

import MustacheFoundation
import MustacheServices

protocol LoginServiceType: Sendable {

    func login(username: String, password: String) async throws

    func signup(fullName: String, email: String, password: String, confirmPassword: String) async throws

    func forgotPassword(email: String) async throws

    func logOut() async throws
}

final class LoginService: LoginServiceType, @unchecked Sendable {

    @Injected(\.installationService)
    private var installationService: any InstallationServiceType

    @Injected(\.asyncCredentialsService)
    private var credentialsService: any AsyncCredentialsServiceType

    @LazyInjected(\.asyncNetworkService)
    private var networkService: any AsyncNetworkServiceType

    @LazyInjected(\.userService)
    private var userService: any UserServiceType

    func login(username: String, password: String) async throws {

        //TODO: Handle missing installationId
        let appInstallationId = try await self.installationService.appInstallationId()
        let request = LoginRequest(username: username, password: password, installationId: appInstallationId)
        let response = try await self.networkService.login(request: request)
        let token = AuthToken(response: response)
        await self.credentialsService.setCredential(type: .oauth, value: token)

    }

    func signup(fullName: String, email: String, password: String, confirmPassword: String) async throws {

        let request = RegisterRequest(firstName: fullName, email: email, password: password, confirmPassword: confirmPassword)
        _ = try await self.networkService.register(request: request)
        // Auto-login with the new credentials so the app proceeds like a normal login.
        try await self.login(username: email, password: password)

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
