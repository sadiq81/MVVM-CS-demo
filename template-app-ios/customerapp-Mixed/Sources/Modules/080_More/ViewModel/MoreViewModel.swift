
import Combine
import SwiftUI

import MustacheServices

@MainActor
final class MoreViewModel: ObservableObject {

    // MARK: State

    @Published var user: UserModel?
    @Published var featureFlags: [FeatureFlag] = []
    @Published var showLogoutAlert = false

    // MARK: Services
    
    @Injected(\.userService)
    private var userService: any UserServiceType
    
    @Injected(\.loginService)
    private var loginService: any LoginServiceType

    private var cancellables = Set<AnyCancellable>()

    // MARK: Init

    init() {
        self.userService.userPublisher
            .receive(on: DispatchQueue.main)
            .assign(to: &self.$user)

        self.userService.featureFlagsPublisher
            .receive(on: DispatchQueue.main)
            .assign(to: &self.$featureFlags)
    }

    // MARK: Functions

    func logOut() {
        Task {
            try await self.loginService.logOut()
            self.userService.clearState()
        }
        NotificationCenter.default.post(name: .logOut, object: nil)
    }

    deinit {
        debugPrint("deinit \(self)")
    }
}
