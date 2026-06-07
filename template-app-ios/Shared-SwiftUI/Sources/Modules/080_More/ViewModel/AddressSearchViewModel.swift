
import Combine
import SwiftUI

import MustacheServices

@MainActor
final class AddressSearchViewModel: ObservableObject {

    // MARK: - State

    @Published var searchText: String = ""
    @Published var suggestions: [AddressSuggestionModel] = []
    @Published var isLoading: Bool = false
    @Published var selectedSuggestion: AddressSuggestionModel?

    // MARK: - Services

    @Injected(\.addressService)
    private var addressService: any AddressServiceType

    private var cancellables = Set<AnyCancellable>()

    // MARK: - Init

    init() {
        self.configureSearch()
    }

    // MARK: - Configure

    private func configureSearch() {
        // Positive path: query >= 3 chars → fetch suggestions
        self.$searchText
            .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
            .removeDuplicates()
            .filter { $0.count >= 3 }
            .sink { [weak self] query in
                self?.fetchSuggestions(for: query)
            }
            .store(in: &self.cancellables)

        // Negative path: short query → clear suggestions
        self.$searchText
            .filter { $0.count < 3 }
            .sink { [weak self] _ in
                self?.suggestions = []
            }
            .store(in: &self.cancellables)
    }

    // MARK: - Functions

    func select(_ suggestion: AddressSuggestionModel) {
        switch suggestion.type {
            case .address:
                // Complete address — select and dismiss
                self.selectedSuggestion = suggestion
            case .streetName, .accessAddress, .unknown:
                // Partial suggestion — refine search text
                self.searchText = suggestion.suggestionText
        }
    }

    private func fetchSuggestions(for query: String) {
        self.isLoading = true
        Task {
            do {
                let results = try await self.addressService.suggestions(for: query)
                self.suggestions = results
                self.isLoading = false

                // Auto-select if single exact match
                if results.count == 1,
                   results[0].type == .address,
                   results[0].text.lowercased() == query.lowercased() {
                    self.selectedSuggestion = results[0]
                }
            } catch {
                self.isLoading = false
                self.suggestions = []
            }
        }
    }

    deinit {
        debugPrint("deinit \(self)")
    }
}
