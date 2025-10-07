import Foundation
import Combine

import MustacheServices

protocol ProductsViewModelType {

    var segmentSubjects: CurrentValueSubject<SegmentState, Never> { get }

    var productsPublisher: AnyPublisher<[ProductModel], Never> { get }

    func publisher(for: SegmentState) -> AnyPublisher<Int, Never>

}

class ProductsViewModel: ProductsViewModelType {
    
    // MARK: Variables

    var segmentSubjects = CurrentValueSubject<SegmentState, Never>(.am)

    var productsPublisher: AnyPublisher<[ProductModel], Never> {
        return Publishers.CombineLatest(self.segmentSubjects, self.productService.favoriteProductsPublisher)
            .map { state, products -> [ProductModel] in
                return products.filter { product in
                    let include = state.include(product)
                    return include
                }
            }
            .eraseToAnyPublisher()
    }
    
    // MARK: Services

    @Injected
    private var productService: ProductServiceType
    
    // MARK: State variables
    
    // MARK: Init
    
    // MARK: Configure
    
    // MARK: functions

    func publisher(for state: SegmentState) -> AnyPublisher<Int, Never> {
        return self.productService.favoriteProductsPublisher
            .map { products -> [ProductModel] in
                return products.filter { product in
                    let include = state.include(product)
                    return include
                }
            }
            .map({ $0.count })
            .eraseToAnyPublisher()
    }

    deinit {
        debugPrint("deinit \(self)")
    }

}

enum SegmentState: Int {
    case am
    case nz

    var filterString: String {
        switch self {
            case .am: return "abcdefghijklm"
            case .nz: return "nopqrstuwvxyz"
        }
    }

    func include(_ product: ProductModel) -> Bool {
        let first = String(product.title.first ?? "a").lowercased()
        let include = self.filterString.contains(first)
        return include
    }
}
