
import Combine
import CoreTelephony

import MustacheServices
import MustacheFoundation

protocol UserViewModelType {

    var user: UserModel? { get }

    var userPublisher: AnyPublisher<UserModel?, Never> { get }
    
    var countries: [Country] { get }

    var featureFlagsPublisher: AnyPublisher<[FeatureFlag], Never> { get }
    
    var addressSearchTextSubject: CurrentValueSubject<String?, Never> { get }
    
    var addressSuggestionsPublisher: AnyPublisher<[AddressSuggestionModel], Never> { get }

    func logOut()

    func save(_ user: UserModel) async throws

    func update(oldPassword: String, password: String, repeatPassword: String) async throws
    
    func suggestions(for: String) async throws -> [AddressSuggestionModel]

}

class UserViewModel: UserViewModelType {
    
    // MARK: functions
    
    var user: UserModel? {
        return self.userService.user
    }

    var userPublisher: AnyPublisher<UserModel?, Never> {
        return self.userService.userPublisher
    }
    
    var countries: [Country] = []

    var featureFlagsPublisher: AnyPublisher<[FeatureFlag], Never> {
        return self.userService.featureFlagsPublisher
    }
    
    var addressSearchTextSubject = CurrentValueSubject<String?, Never>(nil)
    
    var addressSuggestionsPublisher: AnyPublisher<[AddressSuggestionModel], Never> {
        return self.addressSuggestionsSubject.eraseToAnyPublisher()
    }
    private var addressSuggestionsSubject = CurrentValueSubject<[AddressSuggestionModel], Never>([])
    
    // MARK: Services

    @Injected
    private var userService: UserServiceType

    @Injected
    private var logingService: LoginServiceType
    
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
    
    func logOut() { Task {
        try await self.logingService.logOut()
        self.userService.clearState()
    }}

    func save(_ user: UserModel) async throws {
        try await self.userService.save(model: user)
    }
    
    func update(oldPassword: String, password: String, repeatPassword: String) async throws {
        try await self.userService.update(oldPassword: oldPassword, password: password, repeatPassword: repeatPassword)
    }
    
    func suggestions(for query: String) async throws -> [AddressSuggestionModel] {
        return try await self.addressService.suggestions(for: query)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
        debugPrint("deinit \(self)")
    }

}
