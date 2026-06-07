
import Combine
import SwiftUI

import MustacheServices

@MainActor
final class PasswordViewModel: ObservableObject {

    @Published var oldPassword: String = ""
    @Published var password: String = ""
    @Published var repeatPassword: String = ""
    @Published var isValid: Bool = false
    @Published var isSaving: Bool = false
    @Published var errorMessage: String?
    @Published var showError: Bool = false
    @Published var didSave: Bool = false
    
    // MARK: Services
    
    @Injected(\.userService)
    private var userService: any UserServiceType
    
    // MARK: State

    // MARK: Init

    init() {
        Publishers.CombineLatest3(self.$oldPassword, self.$password, self.$repeatPassword)
            .map { old, pw, rpw in
                !old.isEmpty && pw == rpw && pw.count >= 6
            }
            .assign(to: &self.$isValid)
    }

    // MARK: Functions

    func save() async {
        self.isSaving = true
        defer { self.isSaving = false }

        do {
            try await self.userService.update(oldPassword: self.oldPassword, password: self.password, repeatPassword: self.repeatPassword)
            self.didSave = true
        } catch {
            self.errorMessage = error.localizedDescription
            self.showError = true
        }
    }

    deinit {
        debugPrint("deinit \(self)")
    }
}
