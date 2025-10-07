import Foundation
import UIKit

import MustacheFoundation
import MustacheUIKit
import MustacheServices

import Combine

class TabBarCoordinator: NSObject, CoordinatorType {
        
    var baseController: UIViewController? { return self.tabBarController }
    weak var tabBarController: TabBarController?

    weak var parent: CoordinatorType?
    var childCoordinators = NSHashTable<AnyObject>.weakObjects()

    @Injected
    var loggingService: LoggingServiceType
    
    @Injected
    var permissionsService: PermissionsServiceType

    private var cancellables = Set<AnyCancellable>()

    init(parent: CoordinatorType, tabBarController: TabBarController) {
        self.parent = parent
        self.tabBarController = tabBarController
        super.init()
    }

    func start() throws {
        
        self.tabBarController?.delegate = self
        self.tabBarController?.coordinator = self

        let dashboardNavigationController = UINavigationController()
        dashboardNavigationController.tabBarItem = UITabBarItem(title: Strings.Tabbar.dashboard,
                                                                image: UIImage(systemName: "house")?.withRenderingMode(.alwaysTemplate),
                                                                tag: TabBarTransition.dashboard.rawValue)
        let dashboardCoordinator = DashboardCoordinator(parent: self, navigationController: dashboardNavigationController)
        try dashboardCoordinator.start()
        self.childCoordinators.add(dashboardCoordinator)

        let searchNavigationController = UINavigationController()
        searchNavigationController.tabBarItem = UITabBarItem(title: Strings.Tabbar.search,
                                                                image: UIImage(systemName: "magnifyingglass")?.withRenderingMode(.alwaysTemplate),
                                                                tag: TabBarTransition.search.rawValue)
        let searchCoordinator = SearchProductsCoordinator(parent: self, navigationController: searchNavigationController)
        try searchCoordinator.start()
        self.childCoordinators.add(searchCoordinator)

        let productsNavigationController = UINavigationController()
        productsNavigationController.tabBarItem = UITabBarItem(title: Strings.Tabbar.entities,
                                                             image: UIImage(systemName: "bookmark")?.withRenderingMode(.alwaysTemplate),
                                                             tag: TabBarTransition.search.rawValue)
        let productsCooordinator = ProductsCoordinator(parent: self, navigationController: productsNavigationController)
        try productsCooordinator.start()
        self.childCoordinators.add(productsCooordinator)

        let moreNavigationController = UINavigationController()
        moreNavigationController.tabBarItem = UITabBarItem(title: Strings.Tabbar.more,
                                                           image: UIImage(systemName: "ellipsis")?.withRenderingMode(.alwaysTemplate),
                                                           tag: TabBarTransition.more.rawValue)
        let moreCoordinator = MoreCoordinator(parent: self, navigationController: moreNavigationController)
        try moreCoordinator.start()
        self.childCoordinators.add(moreCoordinator)

        self.tabBarController?.viewControllers = [dashboardNavigationController,
                                                 searchNavigationController,
//                                                 DummyAccessViewController(),
                                                 productsNavigationController,
                                                 moreNavigationController,
                                ].compactMap({ $0 })
    }

    func stop() throws {}

    func route(to route: Route) {
        self.childCoordinators.allObjects
            .compactMap({ $0 as? CoordinatorType })
            .forEach { $0.route(to: route) }
    }

    deinit {
        debugPrint("deinit \(self)")
    }

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
            case .products:
                self.loggingService.log(event: .products)
            case .more:
                self.loggingService.log(event: .more)            

        }

    }

    func tabBarController(_ tabBarController: UITabBarController, animationControllerForTransitionFrom fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return SlidingTransition(viewControllers: tabBarController.viewControllers ?? [])
    }
}

enum TabBarTransition: Int, Transition {
    case dashboard
    case search
    case products
    case more
    
}

extension TabBarCoordinator {

    func transition(to transition: Transition) throws {

        if let transition = transition as? TabBarTransition {
            switch transition {
                case .dashboard, .search, .products, .more:
                    self.tabBarController?.selectedIndex = transition.rawValue
            }
        } else {
            try self.parent?.transition(to: transition)
        }
    }
}
