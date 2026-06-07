#if DEBUG

import Combine
import Foundation

final class PreviewFiltersService: FiltersServiceType, @unchecked Sendable {

    var filter: FilterModel? = FilterModel.mockData

    var filterPublisher: AnyPublisher<FilterModel?, Never> {
        return Just(self.filter).eraseToAnyPublisher()
    }

    var selectedCategories: [CategoryFilter] = []

    var selectedCategoriesPublisher: AnyPublisher<[CategoryFilter], Never> {
        return Just(self.selectedCategories).eraseToAnyPublisher()
    }

    var selectedBrands: [BrandFilter] = []

    var selectedBrandsPublisher: AnyPublisher<[BrandFilter], Never> {
        return Just(self.selectedBrands).eraseToAnyPublisher()
    }

    func refresh() async throws {
        // no-op
    }

    func clearState() {
        self.selectedCategories = []
        self.selectedBrands = []
        self.filter = nil
    }

}

#endif
