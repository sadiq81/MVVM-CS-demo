import Foundation

#if DEBUG

extension ProductSearchResult {

    static let mockData = ProductSearchResult(
        search: "iPhone",
        products: ProductModel.mockDataArray,
        total: 5,
        skip: 0,
        limit: 10
    )

}

#endif
