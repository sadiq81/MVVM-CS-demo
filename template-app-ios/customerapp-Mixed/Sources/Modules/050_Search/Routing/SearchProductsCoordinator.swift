import Combine
import SwiftUI
import UIKit

import MustacheServices
import MustacheUIKit

@MainActor
final class SearchProductsCoordinator: NSObject, UIKitCoordinatorType {

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
        try self.transition(to: SearchProductTransition.root)
    }

    func stop() throws {}

    func route(to route: Route) {}

    func transition(to transition: MustacheServices.Transition) throws {
        if let transition = transition as? SearchProductTransition {
            switch transition {
                case .root:
                    let controller = ProductSearchView().hosted(by: self)
                    self.navigationController?.setViewControllers([controller], animated: false)
                    
                case .filter(let filterType):
                    let viewModel = Container.shared.filterSearchViewModel()
                    viewModel.filterType = filterType
                    let controller = FilterSearchView().hosted(by: self)

                    let navController = UINavigationController(rootViewController: controller)
                    self.navigationController?.present(navController, animated: true)

                case .dismissFilter:
                    self.navigationController?.dismiss(animated: true)

                case .details(let product):
                    let viewModel = Container.shared.productDetailViewModel(product)
                    let controller = ProductDetailView(viewModel: viewModel).hosted(by: self)
                    controller.hidesBottomBarWhenPushed = true
                    self.navigationController?.pushViewController(controller, animated: true)
                }
        } else {
            try self.parent?.transition(to: transition)
        }
    }
    
    private func configure() {
        self.navigationController?.tabBarItem = UITabBarItem(title: Strings.Tabbar.search, image: UIImage(systemName: Images.System.search), tag: 1)
    }

    deinit {
        debugPrint("deinit \(self)")
    }
}

// MARK: - Search Transition

enum SearchProductTransition: MustacheServices.Transition {
    case root
    case filter(ProductFilterType)
    case dismissFilter
    case details(ProductModel)
}
