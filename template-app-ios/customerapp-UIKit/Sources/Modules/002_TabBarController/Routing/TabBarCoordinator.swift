import Combine

import MustacheFoundation
import MustacheServices
import MustacheUIKit

@MainActor
final class TabBarCoordinator: NSObject, UIKitCoordinatorType {
        
    var baseController: UIViewController? { return self.tabBarController }
    weak var tabBarController: TabBarController?

    weak var parent: (any CoordinatorType)?
    var childCoordinators = NSHashTable<AnyObject>.weakObjects()

    @Injected(\.loggingService)
    var loggingService: any LoggingServiceType

    init(parent: any CoordinatorType, tabBarController: TabBarController) {
        self.parent = parent
        self.tabBarController = tabBarController
        super.init()
    }

    func start() throws {
        
        self.tabBarController?.delegate = self
        self.tabBarController?.coordinator = self

        let dashboardNavigationController = UINavigationController()
        let dashboardCoordinator = DashboardCoordinator(parent: self, navigationController: dashboardNavigationController)
        try dashboardCoordinator.start()
        self.childCoordinators.add(dashboardCoordinator)

        let searchNavigationController = UINavigationController()
        let searchCoordinator = SearchProductsCoordinator(parent: self, navigationController: searchNavigationController)
        try searchCoordinator.start()
        self.childCoordinators.add(searchCoordinator)

        let favoritesNavigationController = UINavigationController()
        let favoritesCoordinator = FavoritesCoordinator(parent: self, navigationController: favoritesNavigationController)
        try favoritesCoordinator.start()
        self.childCoordinators.add(favoritesCoordinator)

        let moreNavigationController = UINavigationController()
        let moreCoordinator = MoreCoordinator(parent: self, navigationController: moreNavigationController)
        try moreCoordinator.start()
        self.childCoordinators.add(moreCoordinator)

        self.tabBarController?.viewControllers = [dashboardNavigationController,
                                                 searchNavigationController,
                                                 favoritesNavigationController,
                                                 moreNavigationController,
                                ].compactMap({ $0 })
    }

    func stop() throws {}
    
    func transition(to transition: Transition) throws {
        
        if let transition = transition as? TabBarTransition {
            switch transition {
                case .dashboard, .search, .favorites, .more:
                    self.tabBarController?.selectedIndex = transition.rawValue
            }
        } else {
            try self.parent?.transition(to: transition)
        }
    }

    func route(to route: Route) {
        self.childCoordinators.allObjects
            .compactMap({ $0 as? (any CoordinatorType) })
            .forEach { $0.route(to: route) }
    }

    deinit {
        debugPrint("deinit \(self)")
    }

}

enum TabBarTransition: Int, Transition {
    case dashboard
    case search
    case favorites
    case more
}

extension TabBarCoordinator: UITabBarControllerDelegate {

    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {              
        return true
    }

    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        guard let index = tabBarController.viewControllers?.firstIndex(of: viewController),
              let tabbarIndex = TabBarTransition(rawValue: index)
        else { return }

        switch tabbarIndex {
            case .dashboard:
                self.loggingService.log(event: .dashboard)
            case .search:
                self.loggingService.log(event: .filter)
            case .favorites:
                self.loggingService.log(event: .favorites)
            case .more:
                self.loggingService.log(event: .more)            

        }

    }

    func tabBarController(_ tabBarController: UITabBarController, animationControllerForTransitionFrom fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return SlidingTransition(viewControllers: tabBarController.viewControllers ?? [])
    }
}
