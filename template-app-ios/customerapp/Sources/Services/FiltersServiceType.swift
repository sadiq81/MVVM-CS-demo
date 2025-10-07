import Foundation
import MustacheFoundation
import MustacheServices

import Combine
import MustacheCombine

protocol FiltersServiceType: AnyObject {

    var filter: FilterModel? { get }
    var filterPublisher: AnyPublisher<FilterModel?, Never> { get }

    var selectedCategories: [CategoryFilter] { get set }
    var selectedCategoriesPublisher: AnyPublisher<[CategoryFilter], Never> { get }

    var selectedBrands: [BrandFilter] { get set  }
    var selectedBrandsPublisher: AnyPublisher<[BrandFilter], Never> { get }

    func refresh() async throws

    func clearState()

}

class FiltersService: FiltersServiceType {

    @StorageCombineDefault("FiltersService.selectedCategories", mode: .userDefaults(), defaultValue: [])
    var selectedCategories: [CategoryFilter]

    var selectedCategoriesPublisher: AnyPublisher<[CategoryFilter], Never> {
        return self.$selectedCategories
    }

    @StorageCombineDefault("FiltersService.selectedBrands", mode: .userDefaults(), defaultValue: [])
    var selectedBrands: [BrandFilter]

    var selectedBrandsPublisher: AnyPublisher<[BrandFilter], Never> {
        return self.$selectedBrands
    }

    @StorageCombine("FiltersService.filter", mode: .userDefaults())
    var filter: FilterModel?

    var filterPublisher: AnyPublisher<FilterModel?, Never> {
        return self.$filter
    }

    @Injected
    private var networkService: AsyncNetworkServiceType

    func refresh() async throws {
        let response = try await self.networkService.getFilters()
        let model = FilterModel(response: response)
        self.filter = model
    }

    func clearState() {
        self.selectedCategories = []
        self.selectedBrands = []
        self.filter = nil
    }

    deinit {
        debugPrint("deinit \(self)")
    }

}

extension FilterModel {
    convenience init(response: FilterReponse) {
        self.init(
            categories: response.categories.compactMap({ CategoryFilter(rawValue: $0)}),
            brands: response.brands.map({ BrandFilter(value: $0) })
        )
    }
}
