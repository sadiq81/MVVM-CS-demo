import Foundation

import MustacheServices

extension Container {

    // MARK: - SwiftUI ViewModels
    
    var splashViewModel: Factory<SplashViewModel> {
        self { MainActor.assumeIsolated { SplashViewModel() } }.shared
    }
    
    var loginViewModel: Factory<LoginViewModel> {
        self { MainActor.assumeIsolated { LoginViewModel() } }.shared
    }

    var signupViewModel: Factory<SignupViewModel> {
        self { MainActor.assumeIsolated { SignupViewModel() } }.shared
    }

    var forgotPasswordViewModel: Factory<ForgotPasswordViewModel> {
        self { MainActor.assumeIsolated { ForgotPasswordViewModel() } }.shared
    }
        
    var onboardingViewModel: Factory<OnboardingViewModel> {
        self { MainActor.assumeIsolated { OnboardingViewModel() } }.shared
    }
    
    var dashboardViewModel: Factory<DashboardViewModel> {
        self { MainActor.assumeIsolated { DashboardViewModel() } }.shared
    }

    var productSearchViewModel: Factory<ProductSearchViewModel> {
        self { MainActor.assumeIsolated { ProductSearchViewModel() } }.shared
    }
    
    var filterSearchViewModel: Factory<FilterSearchViewModel> {
        self { MainActor.assumeIsolated { FilterSearchViewModel() } }.shared
    }
    
    var productDetailViewModel: ParameterFactory<ProductModel, ProductDetailViewModel> {
        self { product in
            MainActor.assumeIsolated {
                ProductDetailViewModel(product: product)
            }
        }.shared
    }
    
    var favoritesViewModel: Factory<FavoritesViewModel> {
        self { MainActor.assumeIsolated { FavoritesViewModel() } }.shared
    }

    var moreViewModel: Factory<MoreViewModel> {
        self { MainActor.assumeIsolated { MoreViewModel() } }.shared
    }

    var userProfileViewModel: Factory<UserProfileViewModel> {
        self { MainActor.assumeIsolated { UserProfileViewModel() } }.shared
    }

    var passwordViewModel: Factory<PasswordViewModel> {
        self { MainActor.assumeIsolated { PasswordViewModel() } }.shared
    }
    
    var oidAuthorizationViewModel: Factory<OIDAuthorizationViewModel> {
        self { MainActor.assumeIsolated { OIDAuthorizationViewModel() } }.shared
    }

    var pinViewModel: ParameterFactory<Data?, PinViewModel> {
        self { data in
            MainActor.assumeIsolated {
                PinViewModel(data: data)
            }
        }.shared
    }

    var secretViewModel: Factory<SecretViewModel> {
        self { MainActor.assumeIsolated { SecretViewModel() } }.shared
    }

    var addressSearchViewModel: Factory<AddressSearchViewModel> {
        self { MainActor.assumeIsolated { AddressSearchViewModel() } }.shared
    }
        
}

