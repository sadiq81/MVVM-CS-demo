import Foundation
import Combine
import MustacheCombine
import MustacheServices


protocol ProductServiceType {

    var favoriteProducts: [ProductModel] { get set } // If this was fetched via the network the property would be read only

    var favoriteProductsPublisher: AnyPublisher<[ProductModel], Never> { get }

    func fetch(search: String?, brands: String?, categories: String?, limit: Int, skip: Int) async throws -> ProductSearchResult

    func clearState()
}

extension ProductServiceType {

    func fetch() async throws -> ProductSearchResult {
        return try await self.fetch(search: nil, brands: nil, categories: nil, limit: .defaultPageSize, skip: 0)
    }

}

class ProductService: ProductServiceType {

    @StorageCombineDefault("ProductService.favoriteProducts", mode: .userDefaults(), defaultValue: [])
    var favoriteProducts: [ProductModel]

    var favoriteProductsPublisher: AnyPublisher<[ProductModel], Never> {
        return self.$favoriteProducts
    }

    @LazyInjected
    private var networkService: AsyncNetworkServiceType

    func fetch(search: String?, brands: String?, categories: String?, limit: Int, skip: Int) async throws -> ProductSearchResult {
        let response = try await self.networkService.products(search: search,
                                                              brands: brands,
                                                              categories: categories,
                                                              limit: limit,
                                                              skip: skip)

        let models = response.products.map { ProductModel(response: $0)}
        let result = ProductSearchResult(search: search, products: models, total: response.total, skip: response.skip, limit: response.limit)

        return result
    }

    func clearState() {
        self.favoriteProducts = []
    }

    deinit {
        debugPrint("deinit \(self)")
    }

}

extension Int {
    static let defaultPageSize: Int = 20
}

extension ProductModel {
    
    convenience init(response: ProductResponse) {
        self.init(id: response.id,
                  title: response.title,
                  description: response.description,
                  price: response.price,
                  discountPercentage: response.discountPercentage,
                  rating: response.rating,
                  stock: response.stock,
                  brand: response.brand,
                  category: response.category,
                  thumbnail: response.thumbnail,
                  images: response.images)
    }
    
}
