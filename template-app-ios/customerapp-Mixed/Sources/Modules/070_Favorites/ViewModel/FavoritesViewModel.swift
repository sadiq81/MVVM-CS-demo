
import Combine
import SwiftUI

import MustacheServices

// MARK: - Favorites ViewModel

@MainActor
final class FavoritesViewModel: ObservableObject {

    // MARK: State

    @Published var favorites: [ProductModel] = []
    @Published var segmentState: SegmentState = .am
    @Published var amCount: Int = 0
    @Published var nzCount: Int = 0

    // MARK: Services
    
    @Injected(\.productService)
    private var productService: any ProductServiceType
    
    private var cancellables = Set<AnyCancellable>()

    // MARK: Init

    init() {
        self.configure()
    }

    // MARK: Configure

    private func configure() {

        // Filter products based on segment state
        Publishers.CombineLatest(self.$segmentState, self.productService.favoriteProductsPublisher)
            .map { state, products -> [ProductModel] in
                return products.filter { product in
                    state.include(product)
                }
            }
            .receive(on: DispatchQueue.main)
            .assign(to: &self.$favorites)

        // Count for A-M segment
        self.productService.favoriteProductsPublisher
            .map { products -> Int in
                products.filter { SegmentState.am.include($0) }.count
            }
            .receive(on: DispatchQueue.main)
            .assign(to: &self.$amCount)

        // Count for N-Z segment
        self.productService.favoriteProductsPublisher
            .map { products -> Int in
                products.filter { SegmentState.nz.include($0) }.count
            }
            .receive(on: DispatchQueue.main)
            .assign(to: &self.$nzCount)
    }

    deinit {
        debugPrint("deinit \(self)")
    }
}
