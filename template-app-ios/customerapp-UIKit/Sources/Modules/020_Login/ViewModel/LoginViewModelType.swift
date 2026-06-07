import Foundation

import MustacheFoundation
import MustacheServices

protocol LoginViewModelType: Sendable {

    func login(username: String, password: String) async throws

}

final class LoginViewModel: LoginViewModelType, @unchecked Sendable {

    // MARK: Variables
    
    // MARK: Services
    
    @Injected(\.loginService)
    private var loginService: any LoginServiceType

    @LazyInjected(\.userService)
    private var userService: any UserServiceType

    @LazyInjected(\.onboardingService)
    private var onboardingService: any OnboardingServiceType
    
    // MARK: State variables
    
    // MARK: Init
    
    // MARK: Configure
    
    // MARK: functions

    func login(username: String, password: String) async throws {

        try await self.loginService.login(username: username, password: password)
        try await self.userService.refresh()
        try await self.onboardingService.refresh()

    }

    deinit {
        debugPrint("deinit \(self)")
    }

}

// MARK: - Preview

#if DEBUG

final class PreviewLoginViewModel: LoginViewModelType, @unchecked Sendable {

    // MARK: functions

    func login(username: String, password: String) async throws {}

}

#endif
