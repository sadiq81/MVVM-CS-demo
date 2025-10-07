import MustacheFoundation
import MustacheServices


protocol LoginViewModelType {

    func login(username: String, password: String) async throws

}

class LoginViewModel: LoginViewModelType {

    // MARK: Variables
    
    // MARK: Services
    
    @Injected
    private var loginService: LoginServiceType

    @LazyInjected
    private var userService: UserServiceType

    @LazyInjected
    private var onboardingService: OnboardingServiceType
    
    // MARK: State variables
    
    // MARK: Init
    
    // MARK: Configure
    
    // MARK: functions

    func login(username: String, password: String) async throws {

        try await self.loginService.login(username: username, password: password)
        try await self.userService.refresh()
        try await self.onboardingService.refresh()

    }

    deinit {
        debugPrint("deinit \(self)")
    }

}
