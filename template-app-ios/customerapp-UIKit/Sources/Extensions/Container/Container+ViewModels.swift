import Foundation

import MustacheServices

extension Container {

    // MARK: - UIKit ViewModels
    
    var splashScreenViewModel: Factory<any SplashScreenViewModelType> {
        self { MainActor.assumeIsolated { SplashScreenViewModel() } }.shared
    }

    var loginViewModel: Factory<any LoginViewModelType> {
        self { LoginViewModel() }.shared
    }

    var signupViewModel: Factory<any SignupViewModelType> {
        self { SignupViewModel() }.shared
    }

    var forgotPasswordViewModel: Factory<any ForgotPasswordViewModelType> {
        self { ForgotPasswordViewModel() }.shared
    }

    var onboardingViewModel: Factory<any OnboardingViewModelType> {
        self { OnboardingViewModel() }.shared
    }

    var dashboardViewModelType: Factory<any DashboardViewModelType> {
        self { MainActor.assumeIsolated { DashboardViewModel() } }.shared
    }

    var productSearchViewModelType: Factory<any ProductSearchViewModelType> {
        self { MainActor.assumeIsolated { ProductSearchViewModel() } }.shared
    }

    var filterViewModelType: Factory<any FilterViewModelType> {
        self { MainActor.assumeIsolated { ProductFilterViewModel() } }.shared
    }

    var filterSearchViewModelType: Factory<any FilterSearchViewModelType> {
        // Default is overridden at runtime before use
        self { MainActor.assumeIsolated { FilterSearchViewModel() } }.shared
    }

    var productDetailsViewModelType: Factory<any ProductDetailsViewModelType> {
        self { MainActor.assumeIsolated { ProductDetailsViewModel() } }.shared
    }

    var favoritesViewModelType: Factory<any FavoritesViewModelType> {
        self { MainActor.assumeIsolated { FavoritesViewModel() } }.shared
    }

    var userViewModelType: Factory<any UserViewModelType> {
        self { MainActor.assumeIsolated { UserViewModel() } }.shared
    }

    var addressSearchViewModelType: Factory<any AddressSearchViewModelType> {
        self { MainActor.assumeIsolated { AddressSearchViewModel() } }.shared
    }

    var secretViewModelType: Factory<any SecretViewModelType> {
        self { MainActor.assumeIsolated { SecretViewModel() } }.shared
    }

    var pinViewModelType: Factory<PinViewModelType> {
        self { PinViewModel() }.shared
    }

}
