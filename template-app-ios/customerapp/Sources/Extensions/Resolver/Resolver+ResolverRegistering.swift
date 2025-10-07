
import Foundation
import MustacheFoundation
import MustacheServices
import MustacheCombine

extension Resolver: @retroactive ResolverRegistering {

    public static func registerAllServices() {

        // MARK: Network
        // Stores credentials such as oauth token
        self.register(AsyncCredentialsServiceType.self) { AsyncCredentialsService() }.scope(.application)
        
        // Handles expired oauth tokens
        self.register(AsyncTokenServiceType.self) { AsyncTokenService() }.scope(.application)        
        
        // Handles all network calls        
        self.register { AsyncNetworkService() }
            .implements(RefreshTokenServiceType.self)
            .implements(AsyncNetworkServiceType.self)
            .scope(.shared)
        

        // MARK: Services
        self.register(LoggingServiceType.self) { LoggingService() }
        self.register(InstallationServiceType.self) { InstallationService() }
        self.register(LoginServiceType.self) { LoginService() }
        self.register(NotificationServiceType.self) { NotificationService() }
        self.register(OnboardingServiceType.self) { OnboardingService() }
        self.register(DashboardServiceType.self) { DashboardService() }
        self.register(UserServiceType.self) { UserService() }
        self.register(ProductServiceType.self) { ProductService() }
        self.register(FiltersServiceType.self) { FiltersService() }

        
        self.register(PermissionsServiceType.self) { PermissionsService() }
        self.register(Int.self, name: .maxPinAttempt) { 3 }
        self.register(SecureStorageServiceType.self) {
            if Environment.isSimulator {
                return SimulatorSecureStorageService(key: Bundle.main.bundleIdentifier ?? "key")
            } else {
                return SecureStorageService()}
            }
        self.register(AddressServiceType.self) { AddressService() }

        // MARK: ViewModels
        self.register(SplashScreenViewModelType.self) { SplashScreenViewModel() }.scope(.shared)
        
        self.register(LoginViewModelType.self) { LoginViewModel() }.scope(.shared)
        self.register(ForgotPasswordViewModelType.self) { ForgotPasswordViewModel() }.scope(.shared)
        
        self.register(OnboardingViewModelType.self) { OnboardingViewModel() }.scope(.shared)
        
        self.register(DashboardViewModelType.self) { DashboardViewModel() }.scope(.shared)
        
        self.register(ProductSearchViewModelType.self) { ProductSearchViewModel() }.scope(.shared)
        self.register(FilterViewModelType.self) { ProductFilterViewModel() }.scope(.shared)

        self.register(UserViewModelType.self) { UserViewModel() }.scope(.shared)
        self.register(AddressSearchViewModelType.self) { AddressSearchViewModel() }.scope(.shared)
        self.register(SecretViewModelType.self) { SecretViewModel() }.scope(.shared)
        self.register(ProductsViewModelType.self) { ProductsViewModel() }.scope(.shared)
//        self.register(Feature1ViewModelType.self) { Feature1ViewModel() }.scope(.shared)

        // MARK: Can be changed depending on usage
        self.register(PinViewModelType.self) { PinViewModel() }.scope(.shared)

    }
}

