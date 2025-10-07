import Foundation

import MustacheServices
import MustacheFoundation
import Combine

protocol FilterViewModelType {

    func selectedPublisher(for filter: ProductFilterType) -> AnyPublisher<[any ProductFilter], Never>


}

class ProductFilterViewModel: FilterViewModelType {

    // MARK: Variables

    // MARK: Services

    @Injected
    private var filterService: FiltersServiceType

    // MARK: State variables
    
//    private var filter: ProductFilterType
    
    // MARK: Init

    init() {
        self.configure()
    }

    // MARK: Configure

    func configure() { Task {
        try await self.filterService.refresh()
    }}

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
