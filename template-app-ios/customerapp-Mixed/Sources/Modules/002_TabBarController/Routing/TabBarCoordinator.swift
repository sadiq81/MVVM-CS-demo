import Combine
import SwiftUI

import MustacheServices
import MustacheUIKit

@MainActor
final class TabBarCoordinator: NSObject, UIKitCoordinatorType {

    var baseController: UIViewController? { self.tabBarController }
    weak var tabBarController: TabBarController?
    
    weak var parent: (any CoordinatorType)?
    var children = NSHashTable<AnyObject>.weakObjects()
    
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

        // Dashboard tab
        let dashboardNavController = UINavigationController()
        let dashboardCoordinator = DashboardCoordinator(parent: self, navigationController: dashboardNavController)
        self.children.add(dashboardCoordinator)
        try dashboardCoordinator.start()

        // Search tab
        let searchNavController = UINavigationController()
        let searchCoordinator = SearchProductsCoordinator(parent: self, navigationController: searchNavController)
        self.children.add(searchCoordinator)
        try searchCoordinator.start()

        // Favorites tab
        let favoritesNavController = UINavigationController()
        let favoritesCoordinator = FavoritesCoordinator(parent: self, navigationController: favoritesNavController)
        self.children.add(favoritesCoordinator)
        try favoritesCoordinator.start()

        // More tab
        let moreNavController = UINavigationController()
        let moreCoordinator = MoreCoordinator(parent: self, navigationController: moreNavController)
        self.children.add(moreCoordinator)
        try moreCoordinator.start()

        self.tabBarController?.viewControllers = [
            dashboardNavController,
            searchNavController,
            favoritesNavController,
            moreNavController
        ]
    }

    func stop() throws {}

    func route(to route: Route) {
        self.children.allObjects
            .compactMap({ $0 as? (any CoordinatorType) })
            .forEach { $0.route(to: route )}
    }

    func transition(to transition: MustacheServices.Transition) throws {
        
        if let transition = transition as? TabBarTransition {
            switch transition {
                case .dashboard, .search, .favorites, .more:
                    self.tabBarController?.selectedIndex = transition.rawValue
            }
        } else {
            try self.parent?.transition(to: transition)
        }
    }

    deinit {
        debugPrint("deinit \(self)")
    }
}

enum TabBarTransition: Int, MustacheServices.Transition {
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

