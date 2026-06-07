
import Combine
import SwiftUI

import MustacheFoundation
import MustacheServices

@MainActor
final class FilterSearchViewModel: ObservableObject {

    // MARK: State

    @Published var filters: [any ProductFilter] = []
    @Published var searchText: String = ""
    @Published var isDirty: Bool = false

    // MARK: Private

    var filterType: ProductFilterType! {
        didSet { self.configure() }
    }

    private var selectedCategories: [CategoryFilter] = []
    private var selectedBrands: [BrandFilter] = []
    private var cancellables = Set<AnyCancellable>()

    // MARK: Services
    
    @Injected(\.filtersService)
    private var filterService: any FiltersServiceType

    // MARK: Init

    init() {}

    // MARK: Configure

    private func configure() {
        self.cancellables.removeAll()

        // Initialize selected state from service
        self.selectedCategories = self.filterService.selectedCategories
        self.selectedBrands = self.filterService.selectedBrands

        // Eagerly populate filters from cached service data
        self.filters = self.currentFilters

        // Combine search text with filter data
        self.$searchText
            .combineLatest(self.filterPublisher)
            .map { searchText, filters -> [any ProductFilter] in
                guard !searchText.isEmpty else { return filters }
                return filters.filter { $0.localization.localizedCaseInsensitiveContains(searchText) }
            }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] filters in
                self?.filters = filters
            }
            .store(in: &self.cancellables)

        Task { [weak self] in try await self?.filterService.refresh() }
    }

    private var currentFilters: [any ProductFilter] {
        switch self.filterType! {
            case .category:
                return (self.filterService.filter?.categories ?? []).map { $0 as any ProductFilter }
            case .brand:
                return (self.filterService.filter?.brands ?? []).map { $0 as any ProductFilter }
        }
    }

    // MARK: Functions

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
        self.isDirty = self.selectedCategories != self.filterService.selectedCategories ||
            self.selectedBrands != self.filterService.selectedBrands
    }

    func clear() {
        switch self.filterType! {
            case .brand:
                self.selectedBrands.removeAll()
            case .category:
                self.selectedCategories.removeAll()
        }
        self.searchText = ""
        self.isDirty = self.selectedCategories != self.filterService.selectedCategories ||
            self.selectedBrands != self.filterService.selectedBrands
    }

    func save() {
        switch self.filterType! {
            case .brand:
                self.filterService.selectedBrands = self.selectedBrands
                self.selectedBrands.removeAll()
            case .category:
                self.filterService.selectedCategories = self.selectedCategories
                self.selectedCategories.removeAll()
        }
    }

    // MARK: Private

    private var filterPublisher: AnyPublisher<[any ProductFilter], Never> {
        switch self.filterType! {
            case .category:
                return self.filterService.filterPublisher
                    .map { $0?.categories ?? [] }
                    .map({ categories -> [any ProductFilter] in
                        return categories.map({ $0 as (any ProductFilter) })
                    })
                    .eraseToAnyPublisher()
            case .brand:
                return self.filterService.filterPublisher
                    .map { $0?.brands ?? [] }
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
