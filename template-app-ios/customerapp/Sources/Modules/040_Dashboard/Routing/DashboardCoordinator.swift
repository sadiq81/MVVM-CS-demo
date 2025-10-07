import SafariServices

import MustacheFoundation
import MustacheUIKit
import MustacheServices

class DashboardCoordinator: NSObject, CoordinatorType {

    var baseController: UIViewController? { return self.navigationController }

    weak var navigationController: UINavigationController?
    weak var parent: CoordinatorType?

    @Injected
    var loggingService: LoggingServiceType

    init(parent: CoordinatorType, navigationController: UINavigationController) {
        self.parent = parent
        self.navigationController = navigationController
        super.init()
    }

    func start() throws {
        let controller = AppStoryboard.viewController(class: DashboardViewController.self)
        controller.coordinator = self
        self.navigationController?.viewControllers = [controller]
    }

    func stop() throws {}

    func route(to route: Route) { }

    deinit {
        debugPrint("deinit \(self)")
    }

}

enum DashboardTransition: Transition {
    case feature
}

extension DashboardCoordinator {

    func transition(to transition: Transition) throws {

        if let transition = transition as? DashboardTransition {
            switch transition {
                case .feature:
                    break
            }
        } else {
            try self.parent?.transition(to: transition)
        }
    }

}
