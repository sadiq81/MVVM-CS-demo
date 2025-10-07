import Foundation

import MustacheServices
import MustacheFoundation
import Combine

protocol ProductSearchViewModelType: AnyObject {

    var isLoadingPublisher: AnyPublisher<Bool, Never> { get }

    var searchText: String { get set }

    var searchResultsPublisher: AnyPublisher<ProductSearchResult?, Never> { get }

    func fetch(item: Int)

}

extension ProductSearchViewModelType {

    func fetch() {
        self.fetch(item: 0)
    }

}

class ProductSearchViewModel: ProductSearchViewModelType {

    // MARK: Variables

    private var isLoadingValueSubject = CurrentValueSubject<Bool, Never>(false)
    var isLoadingPublisher: AnyPublisher<Bool, Never> {
        return self.isLoadingValueSubject.eraseToAnyPublisher()
    }

    var searchText: String = "" {
        didSet { self.fetch() } // resets the current search
    }

    var selectedBrands: String = "" {
        didSet { self.fetch() } // resets the current search
    }

    var selectedCategories: String = "" {
        didSet { self.fetch() } // resets the current search
    }

    private var searchResultsValueSubject = CurrentValueSubject<ProductSearchResult?, Never>(nil)
    var searchResultsPublisher: AnyPublisher<ProductSearchResult?, Never> {
        return self.searchResultsValueSubject.eraseToAnyPublisher()
    }

    var fetchTasks: [Int: Task<ProductSearchResult?, Error>] = [:]

    // MARK: Services

    @Injected
    private var productService: ProductServiceType

    @Injected
    private var filterServiceType: FiltersServiceType

    // MARK: State variables

    private var lock = NSLock()
    private var cancellables = Set<AnyCancellable>()

    // MARK: Init

    init() {
        self.configure()
    }

    // MARK: Configure

    private func configure() {
        // Initial load

        self.filterServiceType.selectedBrandsPublisher
            .map({ $0.map(\.value).joined(separator: ",") })
            .removeDuplicates()
            .assign(to: \.selectedBrands, on: self)
            .store(in: &self.cancellables)

        self.filterServiceType.selectedCategoriesPublisher
            .map({ $0.map(\.rawValue).joined(separator: ",") })
            .removeDuplicates()
            .assign(to: \.selectedCategories, on: self)
            .store(in: &self.cancellables)

        self.fetch()
    }

    // MARK: functions

    func fetch(item: Int) {

        self.lock.lock()

        if item == 0 {
            // Initial search or new search
            self.fetchTasks.forEach { $1.cancel() }
            self.fetchTasks.removeAll()
            self.searchResultsValueSubject.value = nil
        }

        let page: Int = item / .defaultPageSize

        guard self.fetchTasks[page] == nil else {
            self.lock.unlock()
            return
        }

        if let products = self.searchResultsValueSubject.value?.products,
           products.indices.contains(item),
           products[item] != .none {
            self.lock.unlock()
            return
        }

        let fetchTask = Task { [weak self, page] () throws -> ProductSearchResult? in
            guard let self else { return nil }
            let result = try await self.productService.fetch(search: self.searchText,
                                                             brands: self.selectedBrands,
                                                             categories: self.selectedCategories,
                                                             limit: .defaultPageSize,
                                                             skip: page * .defaultPageSize)
            return result
        }
        
        self.set(task: fetchTask, at: page)

        self.lock.unlock()

        _ = Task.detached(priority: .userInitiated, operation: {

            guard !fetchTask.isCancelled else {
                return
            }

            guard let result: ProductSearchResult = try await fetchTask.value else { return }
            let page = result.skip / .defaultPageSize
        
            self.lock.withLock {
                if var current = self.searchResultsValueSubject.value {
                    current.update(products: result.lastFetched, skip: result.skip, limit: result.limit)
                    self.searchResultsValueSubject.value = current
                } else {
                    self.searchResultsValueSubject.value = result
                }
                self.set(task: nil, at: page)                
            }
        })

    }

    private func set(task: Task<ProductSearchResult?, Error>?, at index: Int) {
        self.fetchTasks[index] = task
        self.isLoadingValueSubject.value = !self.fetchTasks.isEmpty
    }

    deinit {
        debugPrint("deinit \(self)")
    }

}
