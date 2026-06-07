import Combine
import UIKit

import MustacheCombine
import MustacheFoundation
import MustacheServices
import MustacheUIKit

@MainActor
final class LoginCoordinator: NSObject, UIKitCoordinatorType, Completion {

    var baseController: UIViewController? { return self.navigationController }
    weak var navigationController: UINavigationController?

    weak var parent: (any CoordinatorType)?
    
    @Injected(\.onboardingService)
    private var onboardingService: any OnboardingServiceType

    init(parent: any CoordinatorType, navigationController: UINavigationController) {
        self.parent = parent
        self.navigationController = navigationController
        super.init()
    }

    func start() throws {
        try self.transition(to: LoginTransition.root)
    }

    func stop() throws {
        try self.parent?.stop(with: self)
    }

    func route(to route: Route) {}

    deinit {
        debugPrint("deinit \(self)")
    }

}

enum LoginTransition: MustacheServices.Transition {
    case root
    case forgotPassword
    case signup
}

extension LoginCoordinator {

    func transition(to transition: MustacheServices.Transition) throws {

        if let transition = transition as? LoginTransition {
            switch transition {
                case .root:
                    let controller = AppStoryboard.viewController(class: LoginViewController.self)
                    controller.coordinator = self
                    self.navigationController?.setViewControllers([controller], animated: false)

                case .forgotPassword:
                    let controller = AppStoryboard.viewController(class: ForgotPasswordViewController.self)
                    controller.coordinator = self
                    let navigationController = UINavigationController(rootViewController: controller)
                    navigationController.modalPresentationStyle = .fullScreen
                    self.navigationController?.present(navigationController, animated: true)

                case .signup:
                    let controller = AppStoryboard.viewController(class: SignupViewController.self)
                    controller.coordinator = self
                    let navigationController = UINavigationController(rootViewController: controller)
                    navigationController.modalPresentationStyle = .fullScreen
                    self.navigationController?.present(navigationController, animated: true)

            }
        } else {
            try self.parent?.transition(to: transition)
        }
    }
}
