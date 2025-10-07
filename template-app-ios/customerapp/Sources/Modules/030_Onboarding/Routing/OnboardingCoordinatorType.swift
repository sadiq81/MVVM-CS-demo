import UIKit
import MustacheServices

class OnboardingCoordinator: NSObject, CoordinatorType, Completion {
    
    var baseController: UIViewController? { return self.navigationController }
    weak var navigationController: UINavigationController?

    weak var parent: CoordinatorType?
    
    init(parent: CoordinatorType, navigationController: UINavigationController) {
        self.parent = parent
        self.navigationController = navigationController
        super.init()
    }
    
    func start() throws {
        let controller = AppStoryboard.viewController(class: OnboardingViewController.self)
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

extension OnboardingCoordinator {

    func transition(to transition: Transition) throws {
        try self.parent?.transition(to: transition)
    }
}
