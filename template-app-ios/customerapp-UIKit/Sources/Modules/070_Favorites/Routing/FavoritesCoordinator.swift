import Combine
import UIKit

import MustacheFoundation
import MustacheServices
import MustacheUIKit

@MainActor
final class FavoritesCoordinator: NSObject, UIKitCoordinatorType {

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
        try self.transition(to: FavoriteTransition.root)
    }

    private func configure() {
        self.navigationController?.tabBarItem = UITabBarItem(title: Strings.Tabbar.entities, image: UIImage(systemName: Images.System.favorites)?.withRenderingMode(.alwaysTemplate), tag: TabBarTransition.favorites.rawValue)
    }

    func stop() throws {}

    func route(to route: Route) {}

    deinit {
        debugPrint("deinit \(self)")
    }

}

enum FavoriteTransition: Transition {
    case root
    case details(ProductModel)
}

extension FavoritesCoordinator {

    func transition(to transition: Transition) throws {

        if let transition = transition as? FavoriteTransition {
            switch transition {
                case .root:
                    let controller = AppStoryboard.viewController(class: FavoritesViewController.self)
                    controller.coordinator = self
                    self.navigationController?.viewControllers = [controller]

                case .details(let model):
                    
                    let viewModel = Container.shared.productDetailsViewModelType.resolve() as? ProductDetailsViewModel
                    viewModel?.product = model

                    let controller = AppStoryboard.viewController(class: ProductDetailsViewController.self)
                    controller.coordinator = self
                    self.navigationController?.pushViewController(controller, animated: true)
            }
        } else {
            try self.parent?.transition(to: transition)
        }
    }

}
