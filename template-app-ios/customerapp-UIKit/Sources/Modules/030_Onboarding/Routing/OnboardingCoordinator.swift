import Combine
import UIKit

import MustacheServices

@MainActor
final class OnboardingCoordinator: NSObject, UIKitCoordinatorType, Completion {

    var baseController: UIViewController? { return self.navigationController }
    weak var navigationController: UINavigationController?

    weak var parent: (any CoordinatorType)?

    init(parent: any CoordinatorType, navigationController: UINavigationController) {
        self.parent = parent
        self.navigationController = navigationController
        super.init()
    }

    func start() throws {
        try self.transition(to: OnboardingTransition.root)
    }

    func stop() throws {
        try self.parent?.stop(with: self)
    }

    func route(to route: Route) {}

    deinit {
        debugPrint("deinit \(self)")
    }

}

enum OnboardingTransition: Transition {
    case root
}

extension OnboardingCoordinator {

    func transition(to transition: Transition) throws {
        if let transition = transition as? OnboardingTransition {
            switch transition {
                case .root:
                    let controller = AppStoryboard.viewController(class: OnboardingViewController.self)
                    controller.coordinator = self
                    self.navigationController?.setViewControllers([controller], animated: false)
            }
        } else {
            try self.parent?.transition(to: transition)
        }
    }
}
