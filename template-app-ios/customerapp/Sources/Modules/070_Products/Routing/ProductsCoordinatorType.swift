import MustacheFoundation
import MustacheUIKit
import MustacheServices

protocol ProductsCoordinatorType: CoordinatorType {

}

class ProductsCoordinator: NSObject, ProductsCoordinatorType {

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
        let controller = AppStoryboard.viewController(class: ProductsViewController.self)
        controller.coordinator = self
        self.navigationController?.viewControllers = [controller]
    }

    func stop() throws {}

    func route(to route: Route) {}

    deinit {
        debugPrint("deinit \(self)")
    }

}

enum ProductTransition: Transition {
    case details(ProductModel)
}

extension ProductsCoordinator {

    func transition(to transition: Transition) throws {

        if let transition = transition as? ProductTransition {
            switch transition {
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
