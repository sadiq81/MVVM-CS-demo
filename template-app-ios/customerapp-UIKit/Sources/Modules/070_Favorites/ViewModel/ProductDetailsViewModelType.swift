import Combine
import Foundation

import MustacheFoundation
import MustacheServices

protocol ProductDetailsViewModelType: Sendable {

    var product: ProductModel! { get }

    var favoritesProductPublisher: AnyPublisher<[ProductModel], Never> { get }

    var productPublisher: AnyPublisher<ProductModel, Never> { get }

    func toggle(product: ProductModel)

}

@MainActor
final class ProductDetailsViewModel: @preconcurrency ProductDetailsViewModelType {

    // MARK: Variables
    @Published
    var product: ProductModel!
        
    var favoritesProductPublisher: AnyPublisher<[ProductModel], Never> {
        return self.productService.favoriteProductsPublisher
    }

    var productPublisher: AnyPublisher<ProductModel, Never> {
        self.$product.compactMap { $0 }.eraseToAnyPublisher()
    }

    // MARK: Services

    @Injected(\.productService)
    private var productService: any ProductServiceType

    // MARK: Init

    init() {}

    // MARK: functions

    func toggle(product: ProductModel) {
        var products = self.productService.favoriteProducts
        if products.contains(product) {
            products.remove(element: product)
        } else {
            products.append(product)
        }
        self.productService.favoriteProducts = products
    }

    deinit {
        debugPrint("deinit \(self)")
    }
}

// MARK: - Preview

#if DEBUG

final class PreviewProductDetailsViewModel: ProductDetailsViewModelType, @unchecked Sendable {

    // MARK: Variables

    var product: ProductModel! = ProductModel.mockData

    var favoritesProductPublisher: AnyPublisher<[ProductModel], Never> {
        return Just(ProductModel.mockDataArray).eraseToAnyPublisher()
    }

    var productPublisher: AnyPublisher<ProductModel, Never> {
        return Just(ProductModel.mockData).eraseToAnyPublisher()
    }

    // MARK: functions

    func toggle(product: ProductModel) {}

}

#endif
