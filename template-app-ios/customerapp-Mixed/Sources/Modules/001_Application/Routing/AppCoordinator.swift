import Combine
import SwiftUI
import UIKit

import MustacheFoundation
import MustacheServices
import MustacheUIKit

@MainActor
final class AppCoordinator: NSObject, CoordinatorType {
    
    weak var window: UIWindow!

    var children = NSHashTable<AnyObject>.weakObjects()

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

    private var cancellables = Set<AnyCancellable>()

    required init(window: UIWindow) {
        self.window = window
        super.init()
    }

    func start() throws {

        let splashController = SplashView().hosted(by: self)

        self.window?.rootViewController = splashController
        self.window?.makeKeyAndVisible()

        self.configureBindings()
    }

    func stop() throws {}

    func route(to route: Route) {
        self.children.allObjects
            .compactMap({ $0 as? (any CoordinatorType) })
            .forEach({ $0.route(to: route) })
    }

    private func configureBindings() {
        NotificationCenter.default.publisher(for: .logOut)
            .debounce(for: .seconds(1), scheduler: RunLoop.main)
            .filter({ [weak self] _ in
                return self?.userService.user != nil
            })
            .sink(receiveValue: { [weak self] _ in
                guard let self else { return }

                Task {
                    self.dashboardService.clearState()
                    self.filtersService.clearState()
                    self.onboardingService.clearState()
                    self.productService.clearState()
                    self.userService.clearState()
                    try await self.loginService.logOut()
                    await self.credentialsService.clearState()

                    try? self.transition(to: AppTransition.splashCompleted)
                }
            })
            .store(in: &self.cancellables)

        NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)
            .filter({ [weak self] _ in (self?.onboardingService.onboardedCompleted(for: .login) == .completed) })
            .filter({ [weak self] _ in self?.userService.user != nil })
            .sink(receiveValue: { [weak self] _ in
                self?.notificationService.register()
            })
            .store(in: &self.cancellables)
    }
}

// MARK: - Transitions

extension AppCoordinator {

    func transition(to transition: MustacheServices.Transition) throws { Task {
        if let transition = transition as? AppTransition {
            switch transition {

                case .splashCompleted:
                    if self.userService.user.exists {
                        try self.transition(to: AppTransition.loginCompleted)
                    } else {
                        try self.transition(to: AppTransition.login)
                    }

                case .login:
                    let navigationController = UINavigationController()
                    navigationController.setNavigationBarHidden(true, animated: false)
                    let loginCoordinator = LoginCoordinator(parent: self, navigationController: navigationController)
                    try loginCoordinator.start()
                    self.children.add(loginCoordinator)

                    UIView.transition(with: self.window, duration: 0.5, options: .transitionCrossDissolve) {
                        self.window.rootViewController = navigationController
                    }

                case .loginCompleted:
                    guard self.onboardingService.onboardedCompleted(for: .login) == .completed else {
                        try self.transition(to: AppTransition.onboarding)
                        return
                    }
                    
                    let tabBarController = TabBarController()
                    let tabBarCoordinator = TabBarCoordinator(parent: self, tabBarController: tabBarController)
                    try tabBarCoordinator.start()
                    self.children.add(tabBarCoordinator)

                    UIView.transition(with: self.window, duration: 0.5, options: .transitionCrossDissolve) {
                        self.window.rootViewController = tabBarController
                    }

                case .onboarding:
                    let navigationController = UINavigationController()
                    navigationController.setNavigationBarHidden(true, animated: false)
                    let onboardingCoordinator = OnboardingCoordinator(parent: self, navigationController: navigationController)
                    try onboardingCoordinator.start()
                    self.children.add(onboardingCoordinator)

                    UIView.transition(with: self.window, duration: 0.5, options: .transitionCrossDissolve) {
                        self.window.rootViewController = navigationController
                    }

                case .onboardingCompleted:
                    let tabBarController = TabBarController()
                    let tabBarCoordinator = TabBarCoordinator(parent: self, tabBarController: tabBarController)
                    try tabBarCoordinator.start()
                    self.children.add(tabBarCoordinator)

                    UIView.transition(with: self.window, duration: 0.5, options: .transitionCrossDissolve) {
                        self.window.rootViewController = tabBarController
                    }
            }
        }
    }}

    func stop(with completion: Completion?) throws {
        if completion is LoginCoordinator {
            try self.transition(to: AppTransition.loginCompleted)
        } else if completion is OnboardingCoordinator {
            try self.transition(to: AppTransition.onboardingCompleted)
        }
    }
}

// MARK: - App Transition (shared with SwiftUI app)

enum AppTransition: MustacheServices.Transition {
    case splashCompleted
    case login
    case loginCompleted
    case onboarding
    case onboardingCompleted
}
