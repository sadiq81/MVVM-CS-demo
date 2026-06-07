import Combine
import SafariServices
import UIKit

import MustacheFoundation
import MustacheServices
import MustacheUIKit

@MainActor
final class SearchProductsCoordinator: NSObject, UIKitCoordinatorType {

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
        try self.transition(to: SearchProductTransition.root)
    }

    private func configure() {
        self.navigationController?.tabBarItem = UITabBarItem(title: Strings.Tabbar.search, image: UIImage(systemName: Images.System.search)?.withRenderingMode(.alwaysTemplate), tag: TabBarTransition.search.rawValue)
    }

    func stop() throws {}

    func route(to route: Route) { }

    deinit {
        debugPrint("deinit \(self)")
    }

}

enum SearchProductTransition: Transition {
    case root
    case filter(ProductFilterType)
    case details(ProductModel)
}

extension SearchProductsCoordinator {

    func transition(to transition: Transition) throws {

        if let transition = transition as? SearchProductTransition {
            switch transition {
                case .root:
                    let controller = AppStoryboard.viewController(class: ProductSearchViewController.self)
                    controller.coordinator = self
                    self.navigationController?.viewControllers = [controller]

                case .filter(let model):
                    
                    let viewModel = Container.shared.filterSearchViewModelType.resolve() as? FilterSearchViewModel
                    viewModel?.filter = model
                    
                    let controller = AppStoryboard.viewController(class: FilterSearchViewController.self)
                    let navigationController = UINavigationController(rootViewController: controller)
                    self.navigationController?.present(navigationController, animated: true)

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
