
import Combine
import CoreTelephony

import MustacheServices
import MustacheFoundation

protocol AddressSearchViewModelType {

    var addressSearchTextSubject: CurrentValueSubject<String?, Never> { get }
    
    var addressSuggestionsPublisher: AnyPublisher<[AddressSuggestionModel], Never> { get }

    func suggestions(for: String) async throws -> [AddressSuggestionModel]

}

class AddressSearchViewModel: AddressSearchViewModelType {
    
    // MARK: functions
    
    var addressSearchTextSubject = CurrentValueSubject<String?, Never>(nil)
    
    var addressSuggestionsPublisher: AnyPublisher<[AddressSuggestionModel], Never> {
        return self.addressSuggestionsSubject.eraseToAnyPublisher()
    }
    private var addressSuggestionsSubject = CurrentValueSubject<[AddressSuggestionModel], Never>([])
    
    @Injected
    private var addressService: AddressServiceType
    
    // MARK: State variables
    
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: Init
    
    init() {
        self.configure()
    }
    
    // MARK: Configure
    
    private func configure() {
        
        self.addressSearchTextSubject
        // Remove nil or empty values
            .compactMap { $0 }
            .filter { !$0.trimmingCharacters(in: .whitespaces).isEmpty }
        // Only search if at least 3 characters
            .filter { $0.count >= 3 }
        // Debounce to avoid excessive API calls (wait 300ms after user stops typing)
            .debounce(for: .milliseconds(300), scheduler: DispatchQueue.main)
        // Remove duplicate consecutive values
            .removeDuplicates()
        // Switch to async task for each new search query
            .flatMap { [weak self] query -> AnyPublisher<[AddressSuggestionModel], Never> in
                guard let self = self else {
                    return Just([]).eraseToAnyPublisher()
                }
                return Future { promise in
                    Task {
                        do {
                            let suggestions = try await self.suggestions(for: query)
                            promise(.success(suggestions))
                        } catch {
                            promise(.success([]))
                        }
                    }
                }
                .eraseToAnyPublisher()
            }
        // Update the suggestions subject with results
            .sink { [weak self] suggestions in
                self?.addressSuggestionsSubject.send(suggestions)
            }
            .store(in: &cancellables)
        
        // Handle empty/nil search text to clear suggestions
        self.addressSearchTextSubject
            .filter { text in
                guard let text = text else { return true }
                return text.trimmingCharacters(in: .whitespaces).isEmpty || text.count < 3
            }
            .sink { [weak self] _ in
                self?.addressSuggestionsSubject.send([])
            }
            .store(in: &cancellables)
    }
    
    // MARK: functions
    
    func suggestions(for query: String) async throws -> [AddressSuggestionModel] {
        return try await self.addressService.suggestions(for: query)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
        debugPrint("deinit \(self)")
    }

}
