import MustacheFoundation
import UIKit
import MustacheServices

class LoginCoordinator: NSObject, CoordinatorType, Completion {

    var baseController: UIViewController? { return self.navigationController }
    weak var navigationController: UINavigationController?

    weak var parent: CoordinatorType?
    
    @Injected
    private var onboardingService: OnboardingServiceType

    init(parent: CoordinatorType, navigationController: UINavigationController) {
        self.parent = parent
        self.navigationController = navigationController
        super.init()
    }

    func start() throws {
        let controller = AppStoryboard.viewController(class: LoginViewController.self)
        controller.coordinator = self
        self.navigationController?.setViewControllers([controller], animated: false)
    }

    func stop() throws {
        try self.parent?.stop(with: self)
    }

    func route(to route: Route) {}

    deinit {
        debugPrint("deinit \(self)")
    }

}

enum LoginTransition: Transition {
    case forgotPassword
}

extension LoginCoordinator {

    func transition(to transition: Transition) throws {

        if let transition = transition as? LoginTransition {
            switch transition {
                    
                case .forgotPassword:
                    let controller = AppStoryboard.viewController(class: ForgotPasswordViewController.self)
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
