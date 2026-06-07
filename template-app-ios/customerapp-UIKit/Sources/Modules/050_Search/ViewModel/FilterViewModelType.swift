import Combine
import Foundation

import MustacheFoundation
import MustacheServices

protocol FilterViewModelType: Sendable {

    func selectedPublisher(for filter: ProductFilterType) -> AnyPublisher<[any ProductFilter], Never>

}

@MainActor
final class ProductFilterViewModel: @preconcurrency FilterViewModelType {

    // MARK: Variables

    // MARK: Services

    @Injected(\.filtersService)
    private var filterService: any FiltersServiceType

    // MARK: State variables
    
    // MARK: Init

    init() {
        self.configure()
    }

    // MARK: Configure

    func configure() {
        Task { try await self.filterService.refresh() }
    }

    // MARK: functions

    func selectedPublisher(for filter: ProductFilterType) -> AnyPublisher<[any ProductFilter], Never> {
        switch filter {
            case .category:
                return self.filterService.selectedCategoriesPublisher
                    .map({ categories -> [any ProductFilter] in
                        return categories.map({ $0 as (any ProductFilter) })
                    })
                    .eraseToAnyPublisher()
            case .brand:
                return self.filterService.selectedBrandsPublisher
                    .map({ brands -> [any ProductFilter] in
                        return brands.map({ $0 as (any ProductFilter) })
                    })
                    .eraseToAnyPublisher()
        }
    }

    deinit {
        debugPrint("deinit \(self)")
    }

}

// MARK: - Preview

#if DEBUG

final class PreviewFilterViewModel: FilterViewModelType, @unchecked Sendable {

    // MARK: functions

    func selectedPublisher(for filter: ProductFilterType) -> AnyPublisher<[any ProductFilter], Never> {
        switch filter {
            case .category:
                return Just([CategoryFilter.smartphones, CategoryFilter.laptops] as [any ProductFilter]).eraseToAnyPublisher()
            case .brand:
                return Just(BrandFilter.mockDataArray.map { $0 as any ProductFilter }).eraseToAnyPublisher()
        }
    }

}

#endif
