import Foundation
import UIKit

import MustacheServices

final class TabBarController: UITabBarController {
    
    var coordinator: (any CoordinatorType)!

    deinit {
        debugPrint("deinit: \(self)")
    }

}

#if DEBUG
#Preview("TabBarController") {
    let tabBar = TabBarController()
    tabBar.coordinator = PreviewCoordinator()

    let tab1 = UIViewController()
    tab1.view.backgroundColor = .systemBackground
    tab1.tabBarItem = UITabBarItem(title: "Dashboard", image: UIImage(systemName: "house"), tag: 0)

    let tab2 = UIViewController()
    tab2.view.backgroundColor = .systemBackground
    tab2.tabBarItem = UITabBarItem(title: "Search", image: UIImage(systemName: "magnifyingglass"), tag: 1)

    let tab3 = UIViewController()
    tab3.view.backgroundColor = .systemBackground
    tab3.tabBarItem = UITabBarItem(title: "Favorites", image: UIImage(systemName: "bookmark"), tag: 2)

    let tab4 = UIViewController()
    tab4.view.backgroundColor = .systemBackground
    tab4.tabBarItem = UITabBarItem(title: "More", image: UIImage(systemName: "ellipsis"), tag: 3)

    tabBar.viewControllers = [tab1, tab2, tab3, tab4]
    return tabBar
}
#endif

