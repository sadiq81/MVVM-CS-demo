
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
    @Published var didLogin: Bool = false

    // MARK: - Services

    @Injected(\.loginService)
    private var loginService: any LoginServiceType

    // MARK: - Computed Properties

    var isValid: Bool {
        !self.email.isEmpty && !self.password.isEmpty
    }

    // MARK: - Actions

    func login() {
        guard self.isValid else { return }

        self.isLoading = true
        self.errorMessage = nil

        Task {
            do {
                try await self.loginService.login(username: self.email, password: self.password)
                self.isLoading = false
                self.didLogin = true
            } catch {
                self.isLoading = false
                self.errorMessage = error.localizedDescription
                self.showError = true
            }
        }
    }
}
