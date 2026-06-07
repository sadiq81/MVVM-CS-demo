
import SwiftUI

import MustacheServices
import NavigatorUI

// MARK: - Search Destination
@MainActor
enum SearchDestination: NavigationDestination {

    case details(ProductModel)
    case filter(ProductFilterType)

    var body: some View {
        switch self {
            case .details(let product):
                let viewModel = Container.shared.productDetailViewModel(product)
                ProductDetailView(viewModel: viewModel)

            case .filter(let filterType):
                let viewModel = Container.shared.filterSearchViewModel()
                FilterSearchView(filterType: filterType, viewModel: viewModel)
        }
    }

    var method: NavigationMethod {
        switch self {
            case .details:
                return .push
            case .filter:
                return .sheet
        }
    }
}
