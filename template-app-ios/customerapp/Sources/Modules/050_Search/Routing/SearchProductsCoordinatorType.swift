import UIKit
import SafariServices

import MustacheUIKit
import MustacheFoundation
import MustacheServices


protocol SearchProductsCoordinatorType: CoordinatorType {

}

class SearchProductsCoordinator: NSObject, SearchProductsCoordinatorType {

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
        let controller = AppStoryboard.viewController(class: ProductSearchViewController.self)
        controller.coordinator = self
        self.navigationController?.viewControllers = [controller]
    }

    func stop() throws {}

    func route(to route: Route) { }

    deinit {
        debugPrint("deinit \(self)")
    }

}

enum SearchProductTransition: Transition {
    case filter(ProductFilterType)
    case details(ProductModel)
}

extension SearchProductsCoordinator {

    func transition(to transition: Transition) throws {

        if let transition = transition as? SearchProductTransition {
            switch transition {
                case .filter(let model):                    
                    Resolver.register(FilterSearchViewModelType.self) { FilterSearchViewModel(filter: model) }.scope(.shared)
                    let controller = AppStoryboard.viewController(class: FilterSearchViewController.self)
                    let navigationController = UINavigationController(rootViewController: controller)
                    self.navigationController?.present(navigationController, animated: true)
                    
                case .details(let model):
                    Resolver.register(ProductDetailsViewModelType.self) { ProductDetailsViewModel(product: model) }
                    let controller = AppStoryboard.viewController(class: ProductDetailsViewController.self)
                    controller.coordinator = self
                    self.navigationController?.pushViewController(controller, animated: true)
            }
        } else {
            try self.parent?.transition(to: transition)
        }
    }

}
