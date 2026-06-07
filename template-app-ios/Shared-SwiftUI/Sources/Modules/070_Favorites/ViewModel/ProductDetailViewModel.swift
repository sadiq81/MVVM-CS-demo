
import Combine
import SwiftUI

import MustacheFoundation
import MustacheServices

@MainActor
final class ProductDetailViewModel: ObservableObject {

    // MARK: State

    @Published
    var product: ProductModel

    @Published
    var isFavorite: Bool = false

    // MARK: Services
    
    @Injected(\.productService)
    private var productService: any ProductServiceType

    private var cancellables = Set<AnyCancellable>()

    // MARK: Init

    init(product: ProductModel) {
        self.product = product
        self.configure()
    }

    // MARK: Configure

    private func configure() {
        self.cancellables.removeAll()
        self.productService.favoriteProductsPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] favorites in
                guard let self else { return }
                self.isFavorite = favorites.contains(product)
            }
            .store(in: &self.cancellables)
    }

    // MARK: Functions

    func toggleFavorite() {
        var products = self.productService.favoriteProducts
        if products.contains(self.product) {
            products.remove(element: self.product)
        } else {
            products.append(self.product)
        }
        self.productService.favoriteProducts = products
    }

    deinit {
        debugPrint("deinit \(self)")
    }
}
