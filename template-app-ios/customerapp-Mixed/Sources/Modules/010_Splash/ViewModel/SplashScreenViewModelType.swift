import Combine
import Foundation

import MustacheServices

protocol SplashScreenViewModelType: ObservableObject, Sendable {

    // Uses this method to refresh data that should be fetched before the app is ready
    func refresh() async

}

@MainActor
final class SplashScreenViewModel: @preconcurrency SplashScreenViewModelType, ObservableObject {

    // MARK: Variables

    // MARK: Services

    @Injected(\.onboardingService)
    private var onboardingService: any OnboardingServiceType

    @Injected(\.userService)
    private var userService: any UserServiceType
    
    // MARK: State variables

    // MARK: Init

    // MARK: Configure

    // MARK: functions
        
    func refresh() async {
        // Only refresh authenticated data if user is already logged in
        guard self.userService.user != nil else { return }
        try? await self.userService.refresh()
        try? await self.onboardingService.refresh()
    }

    deinit {
        debugPrint("deinit \(self)")
    }
}

// MARK: - Preview

#if DEBUG

final class PreviewSplashScreenViewModel: SplashScreenViewModelType, @unchecked Sendable {

    // MARK: functions

    func refresh() async {}

}

#endif
