import Combine
import Foundation

import MustacheServices

protocol FavoritesViewModelType: Sendable {

    var segmentSubjects: CurrentValueSubject<SegmentState, Never> { get }

    var favoritesPublisher: AnyPublisher<[ProductModel], Never> { get }

    func publisher(for: SegmentState) -> AnyPublisher<Int, Never>

}

@MainActor
final class FavoritesViewModel: @preconcurrency FavoritesViewModelType {
    
    // MARK: Variables

    var segmentSubjects = CurrentValueSubject<SegmentState, Never>(.am)

    var favoritesPublisher: AnyPublisher<[ProductModel], Never> {
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

    @Injected(\.productService)
    private var productService: any ProductServiceType
    
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

// MARK: - Preview

#if DEBUG

final class PreviewFavoritesViewModel: FavoritesViewModelType, @unchecked Sendable {

    // MARK: Variables

    var segmentSubjects = CurrentValueSubject<SegmentState, Never>(.am)

    var favoritesPublisher: AnyPublisher<[ProductModel], Never> {
        return self.segmentSubjects
            .map { state in ProductModel.mockDataArray.filter { state.include($0) } }
            .eraseToAnyPublisher()
    }

    // MARK: functions

    func publisher(for state: SegmentState) -> AnyPublisher<Int, Never> {
        return Just(ProductModel.mockDataArray.filter { state.include($0) }.count).eraseToAnyPublisher()
    }

}

#endif
