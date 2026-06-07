import Foundation

import MustacheServices

extension Container {

    // MARK: - App Services

    var loggingService: Factory<any LoggingServiceType> {
        self { LoggingService() }
    }

    var installationService: Factory<any InstallationServiceType> {
        self { InstallationService() }
    }

    var loginService: Factory<any LoginServiceType> {
        self { LoginService() }
    }

    var notificationService: Factory<any NotificationServiceType> {
        self { NotificationService() }
    }

    var onboardingService: Factory<any OnboardingServiceType> {
        self { OnboardingService() }
    }

    var dashboardService: Factory<any DashboardServiceType> {
        self { DashboardService() }
    }

    var userService: Factory<any UserServiceType> {
        self { UserService() }
    }

    var productService: Factory<any ProductServiceType> {
        self { ProductService() }
    }

    var filtersService: Factory<any FiltersServiceType> {
        self { FiltersService() }
    }

    var addressService: Factory<any AddressServiceType> {
        self { AddressService() }
    }

    var permissionsService: Factory<any PermissionsServiceType> {
        self { PermissionsService() }
    }

    var secureStorageService: Factory<any SecureStorageServiceType> {
        self {
            #if targetEnvironment(simulator)
            SimulatorSecureStorageService(key: Bundle.main.bundleIdentifier ?? "key")
            #else
            SecureStorageService()
            #endif
        }
    }

}
