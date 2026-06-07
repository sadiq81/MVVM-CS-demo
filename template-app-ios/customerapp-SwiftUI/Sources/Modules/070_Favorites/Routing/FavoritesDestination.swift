
import SwiftUI

import MustacheServices
import NavigatorUI

// MARK: - Favorites Destination

@MainActor
enum FavoritesDestination: NavigationDestination {

    case details(ProductModel)

    var body: some View {
        switch self {
            case .details(let product):
                let viewModel = Container.shared.productDetailViewModel(product)
                ProductDetailView(viewModel: viewModel)
        }
    }

    var method: NavigationMethod { .push }
}
