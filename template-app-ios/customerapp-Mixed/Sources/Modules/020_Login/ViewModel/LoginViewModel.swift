
import Combine
import SwiftUI

import MustacheServices

@MainActor
final class LoginViewModel: ObservableObject {

    // MARK: - Published Properties

    @Published var email: String = ""
    @Published var password: String = ""
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var showError: Bool = false

    // MARK: - Services

    @Injected(\.loginService)
    private var loginService: any LoginServiceType

    // MARK: - Computed Properties

    var isValid: Bool {
        !self.email.isEmpty && !self.password.isEmpty
    }

    // MARK: - Actions

    func login() async -> Bool {
        guard self.isValid else { return false }

        self.isLoading = true
        self.errorMessage = nil

        do {
            try await self.loginService.login(username: self.email, password: self.password)
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
