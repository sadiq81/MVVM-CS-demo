import Combine
import SwiftUI
import UIKit

import MustacheServices
import MustacheUIKit

@MainActor
final class DashboardCoordinator: NSObject, UIKitCoordinatorType {

    var baseController: UIViewController? { self.navigationController }

    weak var navigationController: UINavigationController?
    weak var parent: (any CoordinatorType)?

    var children = NSHashTable<AnyObject>.weakObjects()

    private var cancellables = Set<AnyCancellable>()

    init(parent: any CoordinatorType, navigationController: UINavigationController) {
        self.parent = parent
        self.navigationController = navigationController
        super.init()
        self.configure()
    }

    func start() throws {
        try self.transition(to: DashboardTransition.root)
        
    }

    func stop() throws {}

    func route(to route: Route) {}

    func transition(to transition: MustacheServices.Transition) throws {
        if let transition = transition as? DashboardTransition {
            switch transition {
                case .root:
                    let controller = DashboardView().hosted(by: self)
                    self.navigationController?.setViewControllers([controller], animated: false)
            }
        } else {
            try self.parent?.transition(to: transition)
        }
    }
    
    private func configure() {
        self.navigationController?.tabBarItem = UITabBarItem(title: Strings.Tabbar.dashboard, image: UIImage(systemName: Images.System.dashboard), tag: 0)
    }

    deinit {
        debugPrint("deinit \(self)")
    }
}

enum DashboardTransition: MustacheServices.Transition {
    case root
}

