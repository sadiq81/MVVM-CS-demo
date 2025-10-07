# Building Scalable iOS Apps: A Modern MVVM + Coordinator Architecture with Service Dependency Injection

*A comprehensive guide to implementing a production-ready proven iOS architecture that scales*

---

## Introduction

I've wanted to write this post for several years now, so that i could share what I've learned and perhaps help someone build a better app. For full discloure, Claude.ai helped me get started writing this post by looking at the my example codebase, and I've then adjusted a lot of the text afterwards.

Building maintainable iOS applications requires more than just writing code that works. It requires a resilient architecture that separates responsibilities, enables testability, and scales with your team. After years of iterating and refining my iOS architecture, I've settled on a proven combination (insert footnote here: 15+ apps and counting, more than 1 million daily users): **MVVM (Model-View-ViewModel) + Coordinator pattern with Service Dependency Injection**.

In this article, I'll walk you through the complete architecture of a production iOS app, explaining how these patterns work together to create a maintainable, testable, and scalable codebase. 
Some of you might say that this is not how MVVM or Coordinators should be implemented, but again this is my implemenation of the pattern. 

**What you'll learn:**
- How MVVM, Coordinators, and Services work together
- Implementing dependency injection with Resolver
- Managing navigation flows with the Coordinator pattern
- Building reactive ViewModels with Combine
- Structuring a modular codebase

---

## The Problem: Traditional iOS Architecture Challenges

Before diving into the solution, let's acknowledge the common pain points in iOS development:

1. **Massive View Controllers**: UIViewController classes that handle everything—networking, business logic, navigation, and UI updates
2. **Tight Coupling**: Components that are difficult to test in isolation or require deep knowledge of the inner workings of one another
3. **Navigation Spaghetti**: View controllers directly presenting other view controllers, creating tangled dependencies
4. **State Management**: Difficulty managing and propagating state changes across the app
5. **Testability**: Code that's hard to unit test due to tight coupling

Sound familiar? Let's see how we can solve these issues.

---

## Architecture Overview

Our architecture consists of three main layers:

```
┌─────────────────────────────────────────────────┐
│                    View Layer                    │
│  (UIViewController + UIView + Storyboards/XIBs) │
└─────────────────────────────────────────────────┘
                        ↕
┌─────────────────────────────────────────────────┐
│                 ViewModel Layer                  │
│         (Business Logic + Data Transform)        │
└─────────────────────────────────────────────────┘
                        ↕
┌─────────────────────────────────────────────────┐
│                  Service Layer                   │
│    (Networking, Storage, Business Services)      │
└─────────────────────────────────────────────────┘                    

         Navigation Flow Managed By:
┌─────────────────────────────────────────────────┐
│              Coordinator Pattern                 │
│    (AppCoordinator → Module Coordinators)        │
└─────────────────────────────────────────────────┘
```

"High Level MVVMC.png"

---

## Deep Dive: The Coordinator Pattern

### Why Coordinators?

The Coordinator pattern moves navigation complexity by extracting all navigation logic from view controllers. Instead of view controllers presenting other view controllers directly, they delegate navigation decisions to a coordinator. This does not solve the complexity of knowing where in the flow the app is, but it moves it out of the view controllers.

### Implementation

Here's how the coordinator hierarchy works in practice:

```swift
// Base protocol for all coordinators //https://github.com/mustachedk/mustache-ios-kit/blob/main/Sources/MustacheServices/Coordinator/CoordinatorType.swift 
public protocol CoordinatorType: NSObjectProtocol {    
    var baseController: UIViewController? { get }    
    func start() throws    
    func stop() throws    
    func stop(with completion: Completion?) throws    
    func transition(to transition: Transition) throws   
    func route(to route: Route)    
}

// App-level coordinator managing the root flow
class AppCoordinator: CoordinatorType {
     
    weak var window: UIWindow!
    
    var children = NSHashTable<AnyObject>.weakObjects()

    func start() {
        // Decide initial flow based on app state
        if self.userService.user.isNil {
            try? transition(to: AppTransition.login)
        } else {
            try? transition(to: AppTransition.main)
        }
    }

    func transition(to transition: Transition) throws {

        if let transition = transition as? AppTransition {
            switch transition {                                    
                case .splashCompleted:
                // Transition logic
                case .login:
                    let navigationController = UINavigationController() // Controllers must never retain UIKIt controllers
                    navigationController.setNavigationBarHidden(true, animated: false)
                    let loginCoordinator = LoginCoordinator(parent: self, navigationController: navigationController)
                    try loginCoordinator.start()
                    self.children.add(loginCoordinator)
                case .loginCompleted:
                    // Continue to main app
                // ... other transitions
        }
    }
}
```

### Coordinator Hierarchy

The coordinator tree mirrors your app's navigation structure:

```
AppCoordinator (Root)
    ├── LoginCoordinator
    ├── OnboardingCoordinator
    └── TabBarCoordinator
        ├── DashboardCoordinator
        ├── SearchCoordinator
        ├── ProductsCoordinator
        └── MoreCoordinator
            ├── PinCoordinatorType
            └── OIDAuthorizationCoordinatorType
```

What i learned down the way is the inversion of memory ownership, when i first started out experimenting with the coordinator pattern i keept running into memory leaks because of retain cycles, 
it's important to look at the coordinators as something that lives besides UIKit, not on top or below. View controllers reference their coordinator so that when a flow is removed, the coordinator also gets deallocated.

So when do i create a new Coordinator? It really comes down to what feels natural, but as a rule of thumb its whenever you have a new UINavigationController that pushes controllers on its stack. Some coordinators can however reuse their parents
navigation controller if it fits the navigation flow. 

### Key Benefits

1. **Separation of Concerns**: View controllers focus only on displaying UI
2. **Reusable Flows**: Coordinators can be reused across different parts of the app
3. **Testable Navigation**: Navigation logic can be unit tested independently
4. **Deep Linking**: Coordinators handle routing via `route(to:)` method

---

## MVVM: The Heart of Business Logic

### ViewModel Protocol Pattern

Every flow has at least one view model, some have more depending on their complexity. It comes down to what feels natural to seperate into distinct view models. In our pattern we can share the view model instances between several view controller, but all view controllers have a most one view model. This pattern lets us hold flow state in the view model and every view controller should be flow agnostic. So view models hold only flow and transient state. Keep that in mind for later.

```swift
protocol DashboardViewModelType {
    var dashboardPublisher: AnyPublisher<DashboardModel?, Never> { get }
    func refresh() async throws
}
```

### Concrete Implementation

```swift
class DashboardViewModel: DashboardViewModelType {

    // MARK: Variables    
    var userPublisher: AnyPublisher<UserModel?, Never> {
        return self.userService.userPublisher
    }
    
    var dashboardPublisher: AnyPublisher<DashboardModel?, Never> {
        return self.dashboardService.dashboardPublisher
    }
    
    // MARK: Variables

    @Injected
    private var userService: UserServiceType

    @Injected
    private var dashboardService: DashboardServiceType
    
    // MARK: State variables

    // MARK: Init
    
    init() {
        self.configure()
    }
    
    // MARK: Configure

    func configure() { Task {
        try await self.refresh()
    }}
    
    // MARK: functions

    func refresh() async throws {
        try await self.dashboardService.refresh()
    }

    deinit {
        debugPrint("deinit \(self)")
    }

}
```

### View Controller Binding

View controllers bind to ViewModel publishers reactively:

```swift
class DashboardViewController: UIViewController {

    @Injected private var viewModel: DashboardViewModelType
    var coordinator: CoordinatorType!

    private var cancellables = Set<AnyCancellable>()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureBindings()
        ...
    }

    private func configureBindings() {
        // Observe dashboard data
        self.viewModel.dashboardPublisher
            .receive(on: RunLoop.main)
            .sink { [weak self] dashboard in
                self?.updateUI(with: dashboard)
            }
            .store(in: &cancellables)
    }
}
```

"Data Flow.png"

---

## Service Layer: The Data Gatekeepers

Services encapsulate all data operations—networking, parsing from network objects to model objects, persistence, business logic that isn't view-specific and wrapping 3rd party frameworks.
Using services with observable properties makes it easier to keep the UI of all view controllers in memory up to data. When you update something one place, its reflected by all other listerners to the same service.

### Service Protocol Pattern

```swift
protocol DashboardServiceType {
    var dashboard: DashboardModel? { get }
    var dashboardPublisher: AnyPublisher<DashboardModel?, Never> { get }
    func refresh() async throws
    func clearState()
}

protocol UserServiceType {
    var user: UserModel? { get }
    var userPublisher: AnyPublisher<UserModel?, Never> { get }
    ...
    func refresh() async throws
    func save(model: UserModel) async throws
    ...
}

protocol ProductServiceType {
    
    var favoriteProducts: [ProductModel] { get set } // If this was fetched via the network the property would be read only
    var favoriteProductsPublisher: AnyPublisher<[ProductModel], Never> { get }
    func fetch(search: String?, brands: String?, categories: String?, limit: Int, skip: Int) async throws -> ProductSearchResult
    func clearState()

}
```

### Concrete Implementation

```swift
class DashboardService: DashboardServiceType {

    @StorageCombine("DashboardService.dashboard", mode: .userDefaults())
    var dashboard: DashboardModel?

    var dashboardPublisher: AnyPublisher<DashboardModel?, Never> {
        return self.$dashboard
    }

    @LazyInjected
    private var networkService: AsyncNetworkServiceType

    func refresh() async throws {
        let response = try await self.networkService.dashboard()
        let model = DashboardModel(response: response)
        self.dashboard = model
    }

    func clearState() {
        self.dashboard = nil
    }

    deinit {
        debugPrint("deinit \(self)")
    }
}
```

### Service Benefits

1. **Single Responsibility**: Each service handles one domain
2. **Testability**: Easy to mock for unit tests
3. **Reusability**: Services used across multiple ViewModels
4. **Centralized Logic**: Business rules in one place

---

## Dependency Injection with Resolver

Dependency Injection is the glue that holds everything together. We use **Resolver** for compile-time safe DI.

### Registration

All dependencies are registered at app launch:

```swift
extension Resolver: @retroactive ResolverRegistering {

    public static func registerAllServices() {

        // MARK: Network
        // Stores credentials such as oauth token
        self.register(AsyncCredentialsServiceType.self) { AsyncCredentialsService() }.scope(.application)
        
        // Handles expired oauth tokens
        self.register(AsyncTokenServiceType.self) { AsyncTokenService() }.scope(.application)        
        
        // Handles all network calls        
        self.register { AsyncNetworkService() }
            .implements(RefreshTokenServiceType.self)
            .implements(AsyncNetworkServiceType.self)
            .scope(.shared)
        

        // MARK: Services
        self.register(LoggingServiceType.self) { LoggingService() }
        self.register(InstallationServiceType.self) { InstallationService() }
        self.register(LoginServiceType.self) { LoginService() }
        ...
    }
}
```

### Scopes Explained

- **`.application`**: Single instance for the entire app lifetime (e.g., network service)
- **`.shared`**: Shared instance, recreated when all references are released
- **`.unique`**: New instance every time (default)

---

## Module Structure: Keeping Code Organized

The app is organized into numbered modules for clear hierarchy:

```
customerapp/Sources/Modules/
├── 001_Application/          # App delegate, root coordinator
├── 002_TabBarController/     # Main tab bar
├── 003_Common/               # Shared components
├── 010_Splash/               # Splash screen
├── 020_Login/                # Login flow
│   ├── ViewController/
│   │   ├── LoginViewController/
│   │   │   ├── LoginViewController.swift
│   │   │   └── LoginViewController.storyboard
│   │   └── ForgotPasswordViewController/
│   ├── ViewModel/
│   │   ├── LoginViewModelType.swift
│   │   └── LoginViewModel.swift
│   └── Routing/
│       └── LoginCoordinator.swift
├── 030_Onboarding/           # Onboarding flow
├── 040_Dashboard/            # Dashboard module
├── 050_Search/               # Search functionality
├── 070_Products/             # Product catalog
├── 080_More/                 # Settings/More tab
└── 090_Pin/                  # PIN authentication
```

### Module Anatomy

Each module typically contains:

1. **ViewController/**: View controllers with associated storyboards/XIBs
2. **ViewModel/**: ViewModel protocols and implementations
3. **Routing/**: Module-specific coordinator
4. **Cell/**: Custom UITableViewCell/UICollectionViewCell (with XIBs)
5. **View/**: Custom UIView components

---

## Putting It All Together: A Complete Flow

Let's trace a complete user action from input to UI update:

### Scenario: User searches for products

**1. User enters search text**
```swift
// ProductSearchViewController.swift

    private func configureProductBindings() {
        
        ...
        
        self.searchTextField.textPublisher()
            .assign(to: \.searchText, on: self.viewModel)
            .store(in: &self.cancellables)
    }
```

**2. ViewModel processes request**
```swift
// ProductSearchViewModel.swift
    
    var searchText: String = "" {
        didSet { self.fetch() } // resets the current search
    }

    ...

    func fetch(item: Int) {

        let fetchTask = ...
        
        guard let result: ProductSearchResult = try await fetchTask.value else { return }
        let page = result.skip / .defaultPageSize

        ...
    
        if var current = self.searchResultsValueSubject.value {
            current.update(products: result.lastFetched, skip: result.skip, limit: result.limit)
            self.searchResultsValueSubject.value = current
        } else {
            self.searchResultsValueSubject.value = result
        }

    }
```

**3. Service makes network request**
```swift
// ProductService.swift
    func fetch(search: String?, brands: String?, categories: String?, limit: Int, skip: Int) async throws -> ProductSearchResult {
        let response = try await self.networkService.products(search: search,
                                                              brands: brands,
                                                              categories: categories,
                                                              limit: limit,
                                                              skip: skip)

        let models = response.products.map { ProductModel(response: $0)}
        let result = ProductSearchResult(search: search, products: models, total: response.total, skip: response.skip, limit: response.limit)

        return result
    }

```

**4. Network layer executes request**
```swift
// AsyncNetworkService.swift (from MustacheKit)

 public func send<T: Decodable>(endpoint: Endpoint, using decoder: JSONDecoder, retries: Int) async throws -> T {
        
        var request = endpoint.request()
        
        do {
            
            
            ... Handle auth
            
            let (data, response) = try await URLSession.shared.data(for: request)
            
            ... Error code handling
            
            do {
                let model: T = try decoder.decode(T.self, from: data)
                return model
            } catch let error {
                ... Error code handling
            }
        }  catch {
            debugPrint("AsyncNetworkService encountered an error: \(error)")
            throw error
        }
        
    }

```

**5. ViewModel publishes results**
```swift
// ProductSearchViewModel.swift
    
    private var searchResultsValueSubject = CurrentValueSubject<ProductSearchResult?, Never>(nil)
    
    var searchResultsPublisher: AnyPublisher<ProductSearchResult?, Never> {
        return self.searchResultsValueSubject.eraseToAnyPublisher()
    }
```

**6. View observes and updates UI**
```swift
// ProductSearchViewController.swift
    self.viewModel.searchResultsPublisher
            .receive(on: RunLoop.main)
            .sink { [weak self] searchResults in
                
                var snapshot = NSDiffableDataSourceSnapshot<Section, Item>()
                            
                let grouped: [String: [ProductModel]] = searchResults.products.filter { $0.exists }.compactMap({ $0 }).grouped(by: \.brand)
                let sorted = grouped.keys.sorted()
                
                for brand in sorted {
                    guard let group = grouped[brand] else { continue }
                    snapshot.appendSections([.products(group)])
                    let items = group.map { Item.product($0) }
                    snapshot.appendItems(items)
                }                
                
                self?.productDataSource?.apply(snapshot)
            }
            .store(in: &self.cancellables)
```

**7. User taps a product → Coordinator handles navigation**
```swift
// ProductSearchViewController.swift
     func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let itemIdentifier = self.productDataSource?.itemIdentifier(for: indexPath)
        switch itemIdentifier {
            case .product(let product):
                try? self.coordinator.transition(to: SearchProductTransition.details(product))
            default:
                break
        }
        collectionView.deselectItem(at: indexPath, animated: true)    
    }

// SearchCoordinator.swift
    func transition(to transition: Transition) throws {
        if let transition = transition as? SearchProductTransition {
            switch transition {
                
                ...
                    
                case .details(let model):
                    Resolver.register(ProductDetailsViewModelType.self) { ProductDetailsViewModel(product: model) }
                    let controller = AppStoryboard.viewController(class: ProductDetailsViewController.self)
                    controller.coordinator = self
                    self.navigationController?.pushViewController(controller, animated: true)
            }
        } else {
            try self.parent?.transition(to: transition)
        }
    }
```

"Sequence flow.png"

---

## Testing Strategy

This architecture is highly testable. Every service can be injected as a mock instance, every view model can be injected as a mock instance.

---

## Benefits of This Architecture

### ✅ Separation of Concerns
- View controllers only handle UI
- ViewModels contain business logic
- Services handle data operations
- Coordinators manage navigation

### ✅ Testability
- Each layer can be tested independently
- Easy to mock dependencies
- ViewModels testable without UI

### ✅ Scalability
- New features added as self-contained modules
- Clear boundaries between components
- Team members can work on different modules independently

### ✅ Maintainability
- Predictable structure across the app
- Easy to find and fix bugs
- Refactoring is safer with protocols

### ✅ Reusability
- Services shared across features
- Coordinators can be reused for similar flows
- ViewModels can power multiple views

---

## Common Pitfalls to Avoid

### 1. Over-engineering
**Problem**: Creating a ViewModel for every tiny UI component
**Solution**: Use ViewModels for features with business logic, not for static content

### 2. Fat ViewModels
**Problem**: ViewModels handling too much logic
**Solution**: Extract complex logic into dedicated services

### 3. Coordinator Bloat
**Problem**: Single coordinator handling too many transitions
**Solution**: Break into child coordinators for different flows

---

## Migration Strategy

Moving an existing app to this architecture? Here's how:

### Step 1: Start with Dependency Injection
- Set up Resolver
- Register existing services
- Gradually replace manual dependencies

### Step 2: Extract Services
- Identify networking and data logic
- Create service protocols
- Move logic from view controllers to services

### Step 3: Introduce ViewModels
- Start with complex view controllers
- Create ViewModel protocol
- Move business logic to ViewModel
- Bind view to ViewModel with Combine

### Step 4: Implement Coordinators
- Create AppCoordinator
- Extract navigation logic
- Create module-specific coordinators
- Remove direct view controller transitions

### Step 5: Modularize
- Organize by feature modules
- Create clear module boundaries
- Extract shared components

---

## Conclusion

This architecture has served us well in production apps with teams of various sizes. It strikes a balance between structure and pragmatism, providing clear guidelines of where the responsibilites should lie.

**Key Takeaways:**
- **MVVM** separates presentation logic from views
- **Coordinators** handle all navigation, keeping view controllers focused
- **Services** encapsulate data operations and business logic
- **Dependency Injection** enables testability and loose coupling
- **Reactive programming** with Combine we keep the UI in sync across the app

The investment in setting up this architecture pays dividends as your app grows. Your team will thank you when they can:
- Add new features without breaking existing code
- Test components in isolation
- Navigate the codebase with confidence
- Refactor without fear

---

## Resources

**Sample Code**: The complete implementation is available in the [repository](link-to-your-repo)

**Libraries Used**:
- [Resolver](https://github.com/hmlongco/Resolver) - Dependency Injection
- Combine (Native) - Reactive Programming
- Swift Concurrency (Native) - Async/Await

**Further Reading**:
- [Coordinator Pattern by Soroush Khanlou](http://khanlou.com/2015/01/the-coordinator/)
- [Advanced iOS App Architecture](https://www.raywenderlich.com/books/advanced-ios-app-architecture)

---

**What architecture patterns do you use in your iOS apps? Share your experiences in the comments below!**

---

*Follow me for more iOS development insights and architecture patterns.*