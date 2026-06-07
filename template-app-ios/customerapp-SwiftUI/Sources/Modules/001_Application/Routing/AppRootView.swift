
import Combine
import SwiftUI
import UIKit

import MustacheFoundation
@preconcurrency import MustacheServices
import NavigatorUI

// MARK: - App Root View

struct AppRootView: View {

    // MARK: - State

    @State private var screen: AppScreen = .splash

    // MARK: - Services

    @Injected(\.dashboardService)
    private var dashboardService: any DashboardServiceType

    @Injected(\.filtersService)
    private var filtersService: any FiltersServiceType

    @Injected(\.loginService)
    private var loginService: any LoginServiceType

    @Injected(\.asyncCredentialsService)
    private var credentialsService: any AsyncCredentialsServiceType

    @Injected(\.onboardingService)
    private var onboardingService: any OnboardingServiceType

    @Injected(\.notificationService)
    private var notificationService: any NotificationServiceType

    @Injected(\.productService)
    private var productService: any ProductServiceType

    @Injected(\.userService)
    private var userService: any UserServiceType

    // MARK: - Body

    var body: some View {
        ZStack {
            Color(Colors.Background.default.color)
                .ignoresSafeArea()

            switch self.screen {
                case .splash:
                    ManagedNavigationStack(scene: "splash") {
                        SplashView()
                    }
                    .transition(.opacity)

                case .login:
                    ManagedNavigationStack(scene: "login") {
                        LoginView()
                    }
                    .transition(.move(edge: .trailing))

                case .onboarding:
                    OnboardingView()
                        .transition(.move(edge: .trailing))

                case .tabBar:
                    TabBarView()
                        .transition(.move(edge: .trailing))
            }
        }
        .animation(.easeInOut, value: self.screen)
        .onNavigationReceive { (event: AppEvent, _) in
            self.handleEvent(event)
            return .auto
        }
        .onReceive(
            NotificationCenter.default
                .publisher(for: .logOut)
                .debounce(for: .seconds(1), scheduler: RunLoop.main)
        ) { _ in
            self.handleLogout()
        }
        .onReceive(
            NotificationCenter.default
                .publisher(for: UIApplication.didBecomeActiveNotification)
                .filter { [onboardingService] _ in onboardingService.onboardedCompleted(for: .login) == .completed }
                .filter { [userService] _ in userService.user != nil }
        ) { _ in
            self.notificationService.register()
        }
    }

    // MARK: - Event Handling

    private func handleEvent(_ event: AppEvent) {
        switch event {
            case .splashCompleted:
                if self.userService.user.exists {
                    if self.onboardingService.onboardedCompleted(for: .login) == .completed {
                        self.screen = .tabBar
                    } else {
                        self.screen = .onboarding
                    }
                } else {
                    self.screen = .login
                }

            case .loginCompleted:
                if self.onboardingService.onboardedCompleted(for: .login) == .completed {
                    self.screen = .tabBar
                } else {
                    self.screen = .onboarding
                }

            case .onboardingCompleted:
                self.screen = .tabBar

            case .logout:
                self.handleLogout()
        }
    }

    // MARK: - Logout

    private func handleLogout() {
        Task { @MainActor in
            self.dashboardService.clearState()
            self.filtersService.clearState()
            self.onboardingService.clearState()
            self.productService.clearState()
            self.userService.clearState()

            try? await self.loginService.logOut()
            await self.credentialsService.clearState()

            self.screen = .login
        }
    }
}

// MARK: - App Screen (what to display)

enum AppScreen: Equatable {
    case splash
    case login
    case onboarding
    case tabBar
}

// MARK: - App Event (what happened)

enum AppEvent: Hashable {
    case splashCompleted
    case loginCompleted
    case onboardingCompleted
    case logout
}
