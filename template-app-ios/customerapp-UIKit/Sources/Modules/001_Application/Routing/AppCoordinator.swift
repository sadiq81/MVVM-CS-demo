import Combine
import SafariServices
import SwiftUI
import UIKit

import MustacheFoundation
import MustacheServices
import MustacheUIKit

@MainActor
final class AppCoordinator: NSObject, CoordinatorDelegate {

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

        let controller = AppStoryboard.viewController(class: SplashScreenViewController.self)
        controller.coordinator = self

        self.window?.rootViewController = controller
        self.window?.makeKeyAndVisible()

        self.configure()
        self.configureBindings()

    }

    func configure() {
        
    }

    func configureBindings() {
        NotificationCenter.default.publisher(for: .logOut)
            .debounce(for: .seconds(1), scheduler: RunLoop.main)
            .filter({ [weak self] _ in
                // To ensure we dont call clear state more than once
                return self?.userService.user != nil
            })
            .sink(receiveValue: {  [weak self] _ in
                guard let self else { return }
                let dashboardService = self.dashboardService
                let filtersService = self.filtersService
                let onboardingService = self.onboardingService
                let productService = self.productService
                let userService = self.userService
                let loginService = self.loginService
                let credentialsService = self.credentialsService
                Task { @MainActor in

                    dashboardService.clearState()
                    filtersService.clearState()
                    onboardingService.clearState()
                    productService.clearState()
                    onboardingService.clearState()

                    userService.clearState()
                    try await loginService.logOut()
                    await credentialsService.clearState()

                    try? self.transition(to: AppTransition.splashCompleted)
                }
                            
            })
            .store(in: &self.cancellables)

        NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)
            .filter({ [weak self] _ in (self?.onboardingService.onboardedCompleted(for: .login) == .completed) })
            .filter({ [weak self] _ in self?.userService.user != nil })
            .sink(receiveValue: {  [weak self] _ in
                guard let self else { return }
                self.notificationService.register()
            })
            .store(in: &self.cancellables)

    }

    func stop() throws {}

    func route(to route: Route) {
        self.children.allObjects
            .compactMap({ $0 as? (any CoordinatorType) })
            .forEach({ $0.route(to: route) })
    }

    func didFinishLaunchingWith(application: UIApplication, options: [UIApplication.LaunchOptionsKey: Any]?) { }

    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any]) -> Bool {
        return self.urlHandler(url: url)
    }
    
    func application(didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        self.notificationService.received(deviceToken: deviceToken)
    }

    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        if let url = userActivity.webpageURL {
            return self.application(application, open: url, options: [:])
        } else {
            return false
        }
    }

    @discardableResult
    private func urlHandler(url: URL?) -> Bool {
// Keep for reference implementation
//        guard let url = url else { return false }
//        if let appRoute = SomeRoute(url: url) {
//            self.route(to: appRoute)
//            return true
//        }
        return false
    }



}

enum AppTransition: MustacheServices.Transition {
    case splashCompleted
    case login
    case loginCompleted
    case onboarding
    case onboardingCompleted
}


extension AppCoordinator {

    func transition(to transition: MustacheServices.Transition) throws {
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
                    
                    let controller = AppStoryboard.viewController(class: TabBarController.self)
                    
                    let tabBarCoordinator = TabBarCoordinator(parent: self, tabBarController: controller)
                    try tabBarCoordinator.start()
                    self.children.add(tabBarCoordinator)
                    
                    UIView.transition(with: self.window, duration: 0.5, options: .transitionCrossDissolve) {
                        self.window.rootViewController = controller
                    }
                    
                case .onboarding:
                    
                    let navigationController = UINavigationController()
                    navigationController.setNavigationBarHidden(true, animated: false)
                    let onboardingCoordinator = OnboardingCoordinator(parent: self, navigationController: navigationController)
                    try? onboardingCoordinator.start()
                    self.children.add(onboardingCoordinator)
                    
                    UIView.transition(with: self.window, duration: 0.5, options: .transitionCrossDissolve) {
                        self.window.rootViewController = navigationController
                    }
                    
                case .onboardingCompleted:
                    
                    let controller = AppStoryboard.viewController(class: TabBarController.self)
                    let tabBarCoordinator = TabBarCoordinator(parent: self, tabBarController: controller)
                    try tabBarCoordinator.start()
                    self.children.add(tabBarCoordinator)
                    
                    UIView.transition(with: self.window, duration: 0.5, options: .transitionCrossDissolve) {
                        self.window.rootViewController = controller
                    }
                    
            }
        } else if let transition = transition as? OIDAuthorizationTransition {
            switch transition {
                case .validateAge(let presenter):
                    let authorizationCoordinator = OIDAuthorizationCoordinator(parent: self, navigationController: presenter)
                    try authorizationCoordinator.transition(to: transition)
                    self.children.add(authorizationCoordinator)
            }
        }
    }

    func stop(with completion: Completion?) throws {
        if completion is LoginCoordinator {
            try self.transition(to: AppTransition.loginCompleted)
        } else if completion is OnboardingCoordinator {
            try self.transition(to: AppTransition.onboardingCompleted)
        }
    }

}

extension AppCoordinator: UINavigationControllerDelegate, UIViewControllerTransitioningDelegate {

   func navigationController(_ navigationController: UINavigationController,
                              animationControllerFor operation: UINavigationController.Operation,
                              from fromVC: UIViewController,
                              to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {

//       if fromVC is SplashScreenViewController && operation == .pop {
//           return FadePopAnimation()
//       }
       
//        switch operation {
//            case .pop:
//                if fromVC is ModalPushPopTransion {
//                    return ModalPushPopAnimationController(animated: true, isPresenting: false)
//                } else if fromVC is FadeTransition {
//                    return FadeAnimationTransitioning()
//                }
//            case .push:
//                if toVC is ModalPushPopTransion {
//                    return ModalPushPopAnimationController(animated: true, isPresenting: true)
//                } else if toVC is FadeTransition {
//                    return FadeAnimationTransitioning()
//                }
//            case .none:
//                fallthrough
//            @unknown default:
//                break
//        }
        return nil

    }
}

extension AppCoordinator: @preconcurrency SFSafariViewControllerDelegate {

    func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        controller.dismiss(animated: true)
    }

    func safariViewController(_ controller: SFSafariViewController, didCompleteInitialLoad didLoadSuccessfully: Bool) {
        if !didLoadSuccessfully {
            controller.dismiss(animated: true)
        }
    }

}
