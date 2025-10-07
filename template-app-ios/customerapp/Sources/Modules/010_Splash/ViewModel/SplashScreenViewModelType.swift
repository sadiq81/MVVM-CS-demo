import Foundation
import Combine
import UIKit

import MustacheServices

protocol SplashScreenViewModelType {

    // Uses this method to refresh data that should be fetched before the app is ready
    func refresh() async

}

class SplashScreenViewModel: SplashScreenViewModelType {

    // MARK: Variables

    // MARK: Services

    @Injected
    private var onboardingService: OnboardingServiceType

    @Injected
    private var userService: UserServiceType
    
    // MARK: State variables

    // MARK: Init

    // MARK: Configure

    // MARK: functions
        
    func refresh() async {
        // These methods are optional since the user might not be logged in
        try? await self.userService.refresh()
        try? await self.onboardingService.refresh()    
        
    }

    deinit {
        debugPrint("deinit \(self)")
    }
}
