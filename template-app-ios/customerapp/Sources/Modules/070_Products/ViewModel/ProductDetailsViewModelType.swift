import Foundation
import Combine

import MustacheServices

protocol ProductDetailsViewModelType {

    var favoritesProductPublisher: AnyPublisher<[ProductModel], Never> { get }

    var productPublisher: AnyPublisher<ProductModel, Never> { get }

    func toggle(product: ProductModel)

}

class ProductDetailsViewModel: ProductDetailsViewModelType {

    // MARK: Variables
    
    var favoritesProductPublisher: AnyPublisher<[ProductModel], Never> {
        return self.productService.favoriteProductsPublisher
    }

    private var productSubjects = CurrentValueSubject<ProductModel?, Never>(nil)
    var productPublisher: AnyPublisher<ProductModel, Never> {
        return self.productSubjects.compactMap { $0 }.eraseToAnyPublisher()
    }
    
    // MARK: Services

    @Injected
    private var productService: ProductServiceType
    
    // MARK: Init

    init(product: ProductModel) {
        self.productSubjects.value = product
    }

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
