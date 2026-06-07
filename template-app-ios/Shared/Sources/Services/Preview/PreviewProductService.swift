#if DEBUG

import Combine
import Foundation

final class PreviewProductService: ProductServiceType, @unchecked Sendable {

    var favoriteProducts: [ProductModel] = ProductModel.mockDataArray

    var favoriteProductsPublisher: AnyPublisher<[ProductModel], Never> {
        return Just(self.favoriteProducts).eraseToAnyPublisher()
    }

    func fetch(search: String?, brands: String?, categories: String?, limit: Int, skip: Int) async throws -> ProductSearchResult {
        return ProductSearchResult.mockData
    }

    func clearState() {
        self.favoriteProducts = []
    }

}

#endif
