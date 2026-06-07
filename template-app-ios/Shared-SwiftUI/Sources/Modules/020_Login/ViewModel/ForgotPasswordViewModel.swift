
import Combine
import SwiftUI

import MustacheServices

@MainActor
final class ForgotPasswordViewModel: ObservableObject {

    // MARK: - Published Properties

    @Published var email: String = ""
    @Published var isLoading: Bool = false
    @Published var showSuccess: Bool = false
    @Published var showError: Bool = false
    @Published var errorMessage: String = ""

    // MARK: - Services

    @Injected(\.loginService)
    private var loginService: any LoginServiceType

    // MARK: - Computed Properties

    var isValid: Bool {
        !self.email.isEmpty
    }

    // MARK: - Actions

    func resetPassword() {
        guard self.isValid else { return }

        self.isLoading = true

        Task {
            do {
                try await self.loginService.forgotPassword(email: self.email)
                self.isLoading = false
                self.showSuccess = true
            } catch {
                self.isLoading = false
                self.errorMessage = error.localizedDescription
                self.showError = true
            }
        }
    }
}
