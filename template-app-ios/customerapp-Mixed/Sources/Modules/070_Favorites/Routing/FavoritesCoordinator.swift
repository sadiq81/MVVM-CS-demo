import Combine
import SwiftUI
import UIKit

import MustacheServices
import MustacheUIKit

@MainActor
final class FavoritesCoordinator: NSObject, UIKitCoordinatorType {

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
        try self.transition(to: FavoriteTransition.root)
    }

    func stop() throws {}

    func route(to route: Route) {}

    func transition(to transition: MustacheServices.Transition) throws {
        if let transition = transition as? FavoriteTransition {
            switch transition {
                case .root:
                    let controller = FavoritesView().hosted(by: self)
                    controller.title = "Favorites"
                    self.navigationController?.setViewControllers([controller], animated: false)
                    
                case .details(let product):
                    let viewModel = Container.shared.productDetailViewModel(product)
                    let controller = ProductDetailView(viewModel: viewModel).hosted(by: self)
                    self.navigationController?.pushViewController(controller, animated: true)
            }
        } else {
            try self.parent?.transition(to: transition)
        }
    }
    
    private func configure(){
        self.navigationController?.tabBarItem = UITabBarItem(title: Strings.Tabbar.entities, image: UIImage(systemName: Images.System.favorites), tag: 2)
    }

    deinit {
        debugPrint("deinit \(self)")
    }
}

// MARK: - Favorite Transition

enum FavoriteTransition: MustacheServices.Transition {
    case root
    case details(ProductModel)
}
