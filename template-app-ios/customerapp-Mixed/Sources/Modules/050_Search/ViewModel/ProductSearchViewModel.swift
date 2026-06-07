
import Combine
import SwiftUI

import MustacheFoundation
import MustacheServices

@MainActor
final class ProductSearchViewModel: ObservableObject {

    // MARK: State

    @Published var searchText: String = ""
    @Published var searchResults: ProductSearchResult?
    @Published var isLoading = false
    @Published var selectedBrands: [any ProductFilter] = []
    @Published var selectedCategories: [any ProductFilter] = []

    // MARK: Private

    private var fetchTasks: [Int: Task<ProductSearchResult?, Error>] = [:]
    private var lock = NSLock()
    private var cancellables = Set<AnyCancellable>()

    private var internalSearchText: String = "" {
        didSet { self.fetch() }
    }

    private var internalSelectedBrands: String = "" {
        didSet { self.fetch() }
    }

    private var internalSelectedCategories: String = "" {
        didSet { self.fetch() }
    }

    // MARK: Services
    
    @Injected(\.productService)
    private var productService: any ProductServiceType
    
    @Injected(\.filtersService)
    private var filterService: any FiltersServiceType

    // MARK: Init

    init() {
        self.configure()
    }

    // MARK: Configure

    private func configure() {

        // Debounce search text from UI
        self.$searchText
            .removeDuplicates()
            .debounce(for: .milliseconds(300), scheduler: DispatchQueue.main)
            .sink { [weak self] text in
                self?.internalSearchText = text
            }
            .store(in: &self.cancellables)

        // Subscribe to filter service changes
        self.filterService.selectedBrandsPublisher
            .map({ $0.map(\.value).joined(separator: ",") })
            .removeDuplicates()
            .assign(to: \.internalSelectedBrands, on: self)
            .store(in: &self.cancellables)

        self.filterService.selectedCategoriesPublisher
            .map({ $0.map(\.rawValue).joined(separator: ",") })
            .removeDuplicates()
            .assign(to: \.internalSelectedCategories, on: self)
            .store(in: &self.cancellables)

        // Expose selected filters for UI
        self.filterService.selectedBrandsPublisher
            .map({ brands -> [any ProductFilter] in
                return brands.map({ $0 as (any ProductFilter) })
            })
            .receive(on: DispatchQueue.main)
            .sink { [weak self] brands in
                self?.selectedBrands = brands
            }
            .store(in: &self.cancellables)

        self.filterService.selectedCategoriesPublisher
            .map({ categories -> [any ProductFilter] in
                return categories.map({ $0 as (any ProductFilter) })
            })
            .receive(on: DispatchQueue.main)
            .sink { [weak self] categories in
                self?.selectedCategories = categories
            }
            .store(in: &self.cancellables)

        self.fetch()
    }

    // MARK: Computed

    var products: [ProductModel] {
        guard let results = self.searchResults else { return [] }
        return results.products.compactMap { $0 }
    }

    var groupedProducts: [(brand: String, products: [ProductModel])] {
        let existing = self.products
        let grouped = Dictionary(grouping: existing, by: \.brand)
        return grouped.keys.sorted().map { brand in
            (brand: brand, products: grouped[brand] ?? [])
        }
    }

    var hasPlaceholders: Bool {
        guard let results = self.searchResults else { return false }
        return results.products.contains(where: { $0 == nil })
    }

    // MARK: Functions

    func refresh() {
        self.fetch()
    }

    func fetchMore(item: Int) {
        self.fetch(item: item)
    }

    private func fetch(item: Int = 0) {

        self.lock.lock()

        if item == 0 {
            self.fetchTasks.forEach { $1.cancel() }
            self.fetchTasks.removeAll()
            self.searchResults = nil
        }

        let page: Int = item / .defaultPageSize

        guard self.fetchTasks[page] == nil else {
            self.lock.unlock()
            return
        }

        if let products = self.searchResults?.products,
           products.indices.contains(item),
           products[item] != .none {
            self.lock.unlock()
            return
        }

        let fetchTask = Task { [page] () throws -> ProductSearchResult? in
            let result = try await self.productService.fetch(search: self.internalSearchText,
                                                              brands: self.internalSelectedBrands,
                                                              categories: self.internalSelectedCategories,
                                                              limit: .defaultPageSize,
                                                              skip: page * .defaultPageSize)
            return result
        }

        self.set(task: fetchTask, at: page)

        self.lock.unlock()

        Task {

            guard !fetchTask.isCancelled else {
                return
            }

            guard let result: ProductSearchResult = try await fetchTask.value else { return }
            let page = result.skip / .defaultPageSize

            self.lock.withLock {
                if var current = self.searchResults {
                    current.update(products: result.lastFetched, skip: result.skip, limit: result.limit)
                    self.searchResults = current
                } else {
                    self.searchResults = result
                }
                self.set(task: nil, at: page)
            }
        }

    }

    private func set(task: Task<ProductSearchResult?, Error>?, at index: Int) {
        self.fetchTasks[index] = task
        self.isLoading = !self.fetchTasks.isEmpty
    }

    deinit {
        debugPrint("deinit \(self)")
    }
}
