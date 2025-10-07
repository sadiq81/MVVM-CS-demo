import Foundation

import MustacheServices

protocol ForgotPasswordViewModelType {

    func forgotPassword(email: String) async throws

}

class ForgotPasswordViewModel: ForgotPasswordViewModelType {

    // MARK: Variables
    
    // MARK: Services
    
    @Injected
    var loginService: LoginServiceType
    
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
