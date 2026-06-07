import Foundation

import MustacheServices

protocol ForgotPasswordViewModelType: Sendable {

    func forgotPassword(email: String) async throws

}

final class ForgotPasswordViewModel: ForgotPasswordViewModelType, @unchecked Sendable {

    // MARK: Variables
    
    // MARK: Services
    
    @Injected(\.loginService)
    var loginService: any LoginServiceType
    
    // MARK: State variables

    // MARK: Init
    
    // MARK: Configure
    
    // MARK: functions
    
    func forgotPassword(email: String) async throws {
        return try await self.loginService.forgotPassword(email: email)
    }

    deinit {
        debugPrint("deinit \(self)")
    }
}

// MARK: - Preview

#if DEBUG

final class PreviewForgotPasswordViewModel: ForgotPasswordViewModelType, @unchecked Sendable {

    // MARK: functions

    func forgotPassword(email: String) async throws {}

}

#endif
