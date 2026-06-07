
import Combine
import SwiftUI

import MustacheServices

@MainActor
final class SignupViewModel: ObservableObject {

    // MARK: - Published Properties

    @Published var fullName: String = ""
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var confirmPassword: String = ""
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var showError: Bool = false

    // MARK: - Services

    @Injected(\.loginService)
    private var loginService: any LoginServiceType

    // MARK: - Computed Properties

    var isValid: Bool {
        !self.fullName.isEmpty &&
        !self.email.isEmpty &&
        self.password.count >= 8 &&
        self.password == self.confirmPassword
    }

    // MARK: - Actions

    func signup() async -> Bool {
        guard self.isValid else { return false }

        self.isLoading = true
        self.errorMessage = nil

        do {
            try await self.loginService.signup(fullName: self.fullName,
                                               email: self.email,
                                               password: self.password,
                                               confirmPassword: self.confirmPassword)
            self.isLoading = false
            return true
        } catch {
            self.isLoading = false
            self.errorMessage = error.localizedDescription
            self.showError = true
            return false
        }
    }
}
