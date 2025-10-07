import UIKit
import MustacheUIKit
import MustacheServices

import Combine
import SafariServices

protocol AppCoordinatorType: CoordinatorDelegate {

    init(window: UIWindow)

    func didFinishLaunchingWith(application: UIApplication, options: [UIApplication.LaunchOptionsKey: Any]?)

    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any]) -> Bool

    func application(didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data)

}

extension AppCoordinatorType {

    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        if let url = userActivity.webpageURL {
            return self.application(application, open: url, options: [:])
        } else {
            return false
        }
    }
}

final class AppCoordinator: NSObject, AppCoordinatorType {
    
    var baseController: UIViewController? { return nil }
    
    weak var window: UIWindow!

    var children = NSHashTable<AnyObject>.weakObjects()

    @Injected
    private var dashboardService: DashboardServiceType
    
    @Injected
    private var filtersService: FiltersServiceType
    
    @Injected
    private var loginService: LoginServiceType

    @Injected
    private var credentialsService: AsyncCredentialsServiceType

    @Injected
    private var onboardingService: OnboardingServiceType
    
    @Injected
    private var notificationService: NotificationServiceType

    @Injected
    private var productService: ProductServiceType

    @Injected
    private var userService: UserServiceType
    
    private var cancellables = Set<AnyCancellable>()

    required init(window: UIWindow) {
        self.window = window
        super.init()
    }

    func start() throws {

        let splashController = AppStoryboard.viewController(class: SplashScreenViewController.self)
        splashController.coordinator = self
        self.window?.rootViewController = splashController
        
        self.window?.makeKeyAndVisible()

        self.configure()
        self.configureBindings()

    }

    func configure() {
        Resolver.register(SFSafariViewControllerDelegate.self, factory: { self })
    }

    func configureBindings() {
        NotificationCenter.default.publisher(for: .logOut)
            .debounce(for: .seconds(1), scheduler: RunLoop.main)
            .filter({ [weak self] _ in
                return self?.userService.user != nil
            })
            .sink(receiveValue: {  [weak self] _ in
                guard let self else { return }
                
                Task {
                    
                    self.dashboardService.clearState()
                    self.filtersService.clearState()
                    self.onboardingService.clearState()
                    self.productService.clearState()
                    self.onboardingService.clearState()
                    
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
            .sink(receiveValue: {  [weak self] _ in
                guard let self else { return }
                self.notificationService.register()
            })
            .store(in: &self.cancellables)

    }

    func stop() throws {}

    func route(to route: Route) {
        self.children.allObjects
            .compactMap({ $0 as? CoordinatorType })
            .forEach({ $0.route(to: route) })
    }

    func didFinishLaunchingWith(application: UIApplication, options: [UIApplication.LaunchOptionsKey: Any]?) { }

    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any]) -> Bool {
        return self.urlHandler(url: url)
    }
    
    func application(didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        //         self.notificationService.received(deviceToken: deviceToken)
    }

    @discardableResult
    private func urlHandler(url: URL?) -> Bool {
//        guard let url = url else { return false }
//        if let appRoute = MoreTabRoute(url: url) {
//            self.route(to: appRoute)
//            return true
//        }
        return false
    }



}

enum AppTransition: Transition {
    case splashCompleted
    case login
    case loginCompleted
    case onboarding
    case onboardingCompleted
}


extension AppCoordinator {

    func transition(to transition: Transition) throws { Task { @MainActor in
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
    }}
    
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

extension AppCoordinator: SFSafariViewControllerDelegate {

    func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        controller.dismiss(animated: true)
    }

    func safariViewController(_ controller: SFSafariViewController, didCompleteInitialLoad didLoadSuccessfully: Bool) {
        if !didLoadSuccessfully {
            controller.dismiss(animated: true)
        }
    }

}
