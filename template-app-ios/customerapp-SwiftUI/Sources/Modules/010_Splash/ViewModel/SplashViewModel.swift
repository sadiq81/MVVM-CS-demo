import Combine
import Foundation

import MustacheServices

@MainActor
final class SplashViewModel: ObservableObject {

    // MARK: Variables

    @Published var isLoading = false

    // MARK: Services

    @Injected(\.onboardingService)
    private var onboardingService: any OnboardingServiceType

    @Injected(\.userService)
    private var userService: any UserServiceType

    // MARK: Functions

    func refresh() async {
        self.isLoading = true

        if self.userService.user != nil {
            try? await self.userService.refresh()
            try? await self.onboardingService.refresh()
        }

        self.isLoading = false
    }

    deinit {
        debugPrint("deinit \(self)")
    }
}
