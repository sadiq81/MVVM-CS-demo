import Foundation

import MustacheFoundation
import MustacheServices

protocol SignupViewModelType: Sendable {

    func signup(fullName: String, email: String, password: String, confirmPassword: String) async throws

}

final class SignupViewModel: SignupViewModelType, @unchecked Sendable {

    // MARK: Services

    @Injected(\.loginService)
    private var loginService: any LoginServiceType

    @LazyInjected(\.userService)
    private var userService: any UserServiceType

    @LazyInjected(\.onboardingService)
    private var onboardingService: any OnboardingServiceType

    // MARK: functions

    func signup(fullName: String, email: String, password: String, confirmPassword: String) async throws {

        try await self.loginService.signup(fullName: fullName, email: email, password: password, confirmPassword: confirmPassword)
        try await self.userService.refresh()
        try await self.onboardingService.refresh()

    }

    deinit {
        debugPrint("deinit \(self)")
    }

}

// MARK: - Preview

#if DEBUG

final class PreviewSignupViewModel: SignupViewModelType, @unchecked Sendable {

    func signup(fullName: String, email: String, password: String, confirmPassword: String) async throws {}

}

#endif
