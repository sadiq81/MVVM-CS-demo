import Combine
import Foundation

import MustacheFoundation
import MustacheServices

protocol FilterSearchViewModelType: Sendable {

    var isDirty: Bool { get }
    
    var filter: ProductFilterType! { get }

    var filterModel: FilterModel? { get }

    var filterModelPublisher: AnyPublisher<FilterModel?, Never> { get }

    var filterPublisher: AnyPublisher<[any ProductFilter], Never> { get }

    var selectedCategoriesPublisher: AnyPublisher<[CategoryFilter], Never> { get }

    var selectedBrandsPublisher: AnyPublisher<[BrandFilter], Never> { get }

    func selectedPublisher(for filter: ProductFilterType) -> AnyPublisher<[any ProductFilter], Never>

    func isSelected(filter: any ProductFilter) -> Bool

    func toggle(filter: any ProductFilter, isSelected: Bool)

    func clear()

    func save()

}

@MainActor
final class FilterSearchViewModel: @preconcurrency FilterSearchViewModelType {

    // MARK: Variables

    var isDirty: Bool {
        return self.selectedCategories != self.filterService.selectedCategories ||
        self.selectedBrands != self.filterService.selectedBrands
    }
    
    var filter: ProductFilterType! {
        didSet {
            self.configure()
        }
    }

    var filterModel: FilterModel? {
        return self.filterService.filter
    }

    var filterModelPublisher: AnyPublisher<FilterModel?, Never> {
        return self.filterService.filterPublisher
    }
    
    var filterPublisher: AnyPublisher<[any ProductFilter], Never> {
        switch self.filter! {
            case .category:
                return self.categoriesPublisher
                    .map({ brands -> [any ProductFilter] in
                        return brands.map({ $0 as (any ProductFilter) })
                    })
                    .eraseToAnyPublisher()
            case .brand:
                return self.brandsPublisher
                    .map({ brands -> [any ProductFilter] in
                        return brands.map({ $0 as (any ProductFilter) })
                    })
                    .eraseToAnyPublisher()
        }
    }

    var selectedCategories: [CategoryFilter] = []
    var selectedCategoriesPublisher: AnyPublisher<[CategoryFilter], Never> {
        return self.filterService.selectedCategoriesPublisher
    }
    var categoriesPublisher: AnyPublisher<[CategoryFilter], Never> {
        return self.filterService.filterPublisher
            .map { $0?.categories ?? [] }
            .handleEvents(receiveSubscription: { [weak self] _ in
                self?.selectedCategories = self?.filterService.selectedCategories ?? []
            })
            .eraseToAnyPublisher()
    }

    var selectedBrands: [BrandFilter] = []
    var selectedBrandsPublisher: AnyPublisher<[BrandFilter], Never> {
        return self.filterService.selectedBrandsPublisher
    }
    var brandsPublisher: AnyPublisher<[BrandFilter], Never> {
        return self.filterService.filterPublisher
            .map { $0?.brands ?? [] }
            .handleEvents(receiveSubscription: { [weak self] _ in
                self?.selectedBrands = self?.filterService.selectedBrands ?? []
            })
            .eraseToAnyPublisher()
    }

    // MARK: Services

    @Injected(\.filtersService)
    private var filterService: any FiltersServiceType

    
    
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

    func isSelected(filter: any ProductFilter) -> Bool {
        switch filter {
            case let filter as BrandFilter:
                return self.selectedBrands.contains(filter)
            case let filter as CategoryFilter:
                return self.selectedCategories.contains(filter)
            default:
                return false
        }
    }

    func toggle(filter: any ProductFilter, isSelected: Bool) {
        switch filter {
            case let filter as BrandFilter:
                if isSelected {
                    self.selectedBrands.append(filter)
                } else {
                    self.selectedBrands.remove(element: filter)
                }
            case let filter as CategoryFilter:
                if isSelected {
                    self.selectedCategories.append(filter)
                } else {
                    self.selectedCategories.remove(element: filter)
                }
            default:
                break
        }
    }

    func clear() {
        switch self.filter! {
            case .brand:
                self.selectedBrands.removeAll()
            case .category:
                self.selectedCategories.removeAll()
        }
    }

    func save() {
        switch self.filter! {
            case .brand:
                self.filterService.selectedBrands = self.selectedBrands
                self.selectedBrands.removeAll()
            case .category:
                self.filterService.selectedCategories = self.selectedCategories
                self.selectedCategories.removeAll()
        }
    }

    deinit {
        debugPrint("deinit \(self)")
    }

}

// MARK: - Preview

#if DEBUG

final class PreviewFilterSearchViewModel: FilterSearchViewModelType, @unchecked Sendable {

    // MARK: Variables

    var filter: ProductFilterType! = .brand

    var isDirty: Bool {
        return false
    }

    var filterModel: FilterModel? {
        return FilterModel.mockData
    }

    var filterModelPublisher: AnyPublisher<FilterModel?, Never> {
        return Just(FilterModel.mockData).eraseToAnyPublisher()
    }

    var filterPublisher: AnyPublisher<[any ProductFilter], Never> {
        return Just(FilterModel.mockData.categories.map { $0 as any ProductFilter }).eraseToAnyPublisher()
    }

    var selectedCategoriesPublisher: AnyPublisher<[CategoryFilter], Never> {
        return Just([CategoryFilter.smartphones]).eraseToAnyPublisher()
    }

    var selectedBrandsPublisher: AnyPublisher<[BrandFilter], Never> {
        return Just([BrandFilter.mockData]).eraseToAnyPublisher()
    }

    // MARK: functions

    func selectedPublisher(for filter: ProductFilterType) -> AnyPublisher<[any ProductFilter], Never> {
        switch filter {
            case .category:
                return Just([CategoryFilter.smartphones] as [any ProductFilter]).eraseToAnyPublisher()
            case .brand:
                return Just([BrandFilter.mockData] as [any ProductFilter]).eraseToAnyPublisher()
        }
    }

    func isSelected(filter: any ProductFilter) -> Bool {
        return false
    }

    func toggle(filter: any ProductFilter, isSelected: Bool) {}

    func clear() {}

    func save() {}

}

#endif
