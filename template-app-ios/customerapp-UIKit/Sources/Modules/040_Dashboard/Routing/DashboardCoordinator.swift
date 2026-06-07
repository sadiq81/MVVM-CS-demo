import Combine
import SafariServices
import UIKit

import MustacheFoundation
import MustacheServices
import MustacheUIKit

@MainActor
final class DashboardCoordinator: NSObject, UIKitCoordinatorType {

    var baseController: UIViewController? { return self.navigationController }

    weak var navigationController: UINavigationController?
    weak var parent: (any CoordinatorType)?

    @Injected(\.loggingService)
    var loggingService: any LoggingServiceType

    init(parent: any CoordinatorType, navigationController: UINavigationController) {
        self.parent = parent
        self.navigationController = navigationController
        super.init()
        self.configure()
    }

    func start() throws {
        try self.transition(to: DashboardTransition.root)
    }

    private func configure() {
        self.navigationController?.tabBarItem = UITabBarItem(title: Strings.Tabbar.dashboard, image: UIImage(systemName: Images.System.dashboard)?.withRenderingMode(.alwaysTemplate), tag: TabBarTransition.dashboard.rawValue)
    }
    
    func transition(to transition: Transition) throws {
        
        if let transition = transition as? DashboardTransition {
            switch transition {
                case .root:
                    let controller = AppStoryboard.viewController(class: DashboardViewController.self)
                    controller.coordinator = self
                    self.navigationController?.viewControllers = [controller]

                case .feature:
                    break
            }
        } else {
            try self.parent?.transition(to: transition)
        }
    }


    func stop() throws {}

    func route(to route: Route) { }

    deinit {
        debugPrint("deinit \(self)")
    }

}

enum DashboardTransition: Transition {
    case root
    case feature
}
