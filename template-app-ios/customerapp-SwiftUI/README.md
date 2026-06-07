# SwiftUI App Architecture (App 3 of 3)

This is the **Pure SwiftUI** app — one of three showcase apps demonstrating different approaches to the MVVM-CS (Model-View-ViewModel + Coordinator + Services) architecture:

1. **customerapp-UIKit** — Pure UIKit with storyboards and UIViewControllers
2. **customerapp-Mixed** — UIKit coordinators wrapping SwiftUI views via UIHostingController
3. **customerapp-SwiftUI** (this app) — Pure SwiftUI with NavigationStack-based coordinators

SwiftUI views in this app that use the `HostingCoordinator` pattern are **shared with the Mixed app** via file-level symlinks. This means changes to shared views here automatically apply to the Mixed app as well.

## Architecture Overview

The SwiftUI app maintains the same MVVM-CS architectural patterns:

- **MVVM Pattern**: Separation of business logic (ViewModel) from UI (View)
- **Coordinator Pattern**: Centralized navigation management via SwiftUI coordinators
- **HostingCoordinator**: Bridge pattern from MustacheServices — shared views use `@EnvironmentObject var coordinator: HostingCoordinator` so they work in both UIKit and SwiftUI coordinator contexts
- **Dependency Injection**: Using Resolver for service injection
- **Combine**: Reactive programming for data flow

## Directory Structure

```
customerapp-SwiftUI/
├── Resources/                      # Assets and resources
├── Sources/
│   ├── DesignSystem/              # Shared SwiftUI design system
│   │   ├── FontExtensions.swift
│   │   └── ViewModifiers.swift
│   ├── Extensions/                # SwiftUI-specific extensions
│   └── Modules/
│       ├── 001_Application/       # App entry and routing
│       │   ├── App/
│       │   │   └── SwiftUIApp.swift              # @main entry point
│       │   └── Routing/
│       │       ├── SwiftUICoordinatorType.swift  # Base coordinator protocol
│       │       ├── SwiftUIAppCoordinator.swift   # Main app coordinator
│       │       └── AppCoordinatorView.swift      # Root navigation view
│       ├── 002_TabBar/
│       │   └── TabBarCoordinatorView.swift       # Main tab bar
│       ├── 010_Splash/
│       │   └── SplashView.swift                  # Splash screen
│       ├── 020_Login/                            # Login flow
│       │   ├── Routing/
│       │   │   ├── LoginCoordinator.swift
│       │   │   └── LoginCoordinatorView.swift
│       │   └── Views/
│       │       ├── LoginView.swift
│       │       ├── LoginViewModel.swift
│       │       └── ForgotPasswordView.swift
│       └── 030_Onboarding/
│           └── OnboardingCoordinatorView.swift   # Onboarding flow
└── Vendor/                         # Third-party code
```

**Note:** The module numbering (001, 002, 010, etc.) matches the UIKit app structure for consistency.

## Key Concepts

### 1. SwiftUI Coordinators

Unlike UIKit coordinators that manage UIViewControllers, SwiftUI coordinators manage navigation state:

```swift
@MainActor
final class LoginCoordinator: ObservableObject, SwiftUICoordinatorType {
    @Published var navigationPath: [LoginPath] = []
    @Published var presentedSheet: LoginPath?

    weak var parent: (any SwiftUICoordinatorType)?
    var children: [any SwiftUICoordinatorType] = []
}
```

Key differences from UIKit:
- Use `@Published` properties for navigation state
- Conform to `ObservableObject` instead of `NSObject`
- Use `NavigationStack` with path binding instead of `UINavigationController`

### 2. Navigation State

The app uses enums to represent navigation states:

```swift
enum NavigationState: Equatable, Identifiable {
    case splash
    case login
    case onboarding
    case tabBar
    case modal(AnyHashable)
}
```

The `AppCoordinator` publishes the current navigation state, and `AppCoordinatorView` renders the appropriate view:

```swift
switch coordinator.navigationState {
case .splash:
    makeSplashView()
case .login:
    makeLoginFlow()
case .tabBar:
    makeTabBarView()
}
```

### 3. Coordinator Hierarchy

```
SwiftUIAppCoordinator (Root)
    ├── LoginCoordinator
    │   └── Manages login flow navigation
    ├── OnboardingCoordinator
    │   └── Manages onboarding flow
    └── TabBarCoordinator
        ├── DashboardCoordinator
        ├── SearchCoordinator
        ├── ProfileCoordinator
        └── MoreCoordinator
```

Parent-child relationships are maintained using weak references:

```swift
weak var parent: (any SwiftUICoordinatorType)?
var children: [any SwiftUICoordinatorType] = []
```

### 4. Transitions

Coordinators handle transitions using the same `Transition` protocol:

```swift
enum AppTransition: MustacheServices.Transition {
    case splashCompleted
    case login
    case loginCompleted
    case onboarding
    case onboardingCompleted
}

func transition(to transition: MustacheServices.Transition) throws {
    guard let appTransition = transition as? AppTransition else { return }

    switch appTransition {
    case .login:
        navigationState = .login
    case .loginCompleted:
        navigationState = .tabBar
    }
}
```

### 5. ViewModels

ViewModels remain similar to the UIKit version but use `@MainActor`:

```swift
@MainActor
final class LoginViewModel: ObservableObject {
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var isLoading: Bool = false

    @Injected private var loginService: LoginServiceType

    func login(completion: @escaping (Bool) -> Void) {
        Task {
            try await loginService.login(email: email, password: password)
            completion(true)
        }
    }
}
```

### 6. Dependency Injection

Uses the same Resolver setup as UIKit:

```swift
@Injected private var loginService: LoginServiceType
@LazyInjected private var userService: UserServiceType
```

Services are registered in `Resolver+ResolverRegistering.swift` (shared with UIKit).

## Creating a New Module

### 1. Create Module Structure

Follow the numbering convention to match the UIKit app structure:

```
Modules/
└── 0XX_MyFeature/              # Use appropriate number (e.g., 040, 050, etc.)
    ├── Routing/
    │   ├── MyFeatureCoordinator.swift
    │   └── MyFeatureCoordinatorView.swift
    └── Views/
        ├── MyFeatureView.swift
        └── MyFeatureViewModel.swift
```

**Module Numbering:**
- `001_Application` - App entry point and main coordinator
- `002_TabBar` - Main tab bar controller
- `003_Common` - Shared components
- `010_Splash` - Splash screen
- `020_Login` - Login flow
- `030_Onboarding` - Onboarding flow
- `040_Dashboard` - Dashboard
- `050_Search` - Search functionality
- `060+` - Additional features

### 2. Create Coordinator

```swift
@MainActor
final class MyFeatureCoordinator: ObservableObject, SwiftUICoordinatorType {
    @Published var navigationPath: [MyFeaturePath] = []

    weak var parent: (any SwiftUICoordinatorType)?
    var children: [any SwiftUICoordinatorType] = []

    func start() {
        navigationPath = [.main]
    }

    func transition(to transition: MustacheServices.Transition) throws {
        // Handle transitions
    }
}

enum MyFeaturePath: NavigationPathItem {
    case main
    case detail
}
```

### 3. Create CoordinatorView

```swift
struct MyFeatureCoordinatorView: View {
    @StateObject private var coordinator: MyFeatureCoordinator
    @EnvironmentObject private var parentCoordinator: ParentCoordinator

    init() {
        _coordinator = StateObject(wrappedValue: MyFeatureCoordinator())
    }

    var body: some View {
        NavigationStack(path: $coordinator.navigationPath) {
            Color.clear
                .navigationDestination(for: MyFeaturePath.self) { path in
                    destinationView(for: path)
                }
        }
        .onAppear {
            coordinator.parent = parentCoordinator
            coordinator.start()
        }
        .environmentObject(coordinator)
    }
}
```

### 4. Create View and ViewModel

```swift
struct MyFeatureView: View {
    @EnvironmentObject private var coordinator: MyFeatureCoordinator
    @StateObject private var viewModel: MyFeatureViewModel

    init() {
        _viewModel = StateObject(wrappedValue: MyFeatureViewModel())
    }

    var body: some View {
        // View implementation
    }
}

@MainActor
final class MyFeatureViewModel: ObservableObject {
    @Published var state: ViewState = .loading
    @Injected private var service: ServiceType

    // ViewModel implementation
}
```

## Navigation Patterns

### Push Navigation

Use `NavigationStack` with path binding:

```swift
@Published var navigationPath: [MyPath] = []

// Push
navigationPath.append(.detail)

// Pop
navigationPath.removeLast()

// Pop to root
navigationPath.removeAll()
```

### Modal Presentation

Use `@Published` sheet presentation:

```swift
@Published var presentedSheet: SheetType?

// Present
presentedSheet = .settings

// In view:
.sheet(item: $coordinator.presentedSheet) { sheet in
    destinationSheet(for: sheet)
}
```

### Full Screen Cover

```swift
@Published var presentedCover: CoverType?

.fullScreenCover(item: $coordinator.presentedCover) { cover in
    destinationCover(for: cover)
}
```

## Best Practices

1. **Always use @MainActor**: SwiftUI views and coordinators should run on the main thread
2. **Weak parent references**: Prevent retain cycles with `weak var parent`
3. **StateObject for coordinators**: Use `@StateObject` to own coordinators, `@EnvironmentObject` to pass them down
4. **Explicit navigation types**: Use enums conforming to `Hashable` for type-safe navigation
5. **Separation of concerns**: Keep navigation logic in coordinators, business logic in ViewModels, UI in Views
6. **Reuse services**: Share the same service layer with UIKit (defined in `Services/`)

## Shared Views (via Symlinks)

The following SwiftUI views are shared with `customerapp-Mixed` via file-level symlinks. They use `HostingCoordinator` instead of concrete coordinator types, making them agnostic to the hosting environment:

- `SplashView.swift` — Uses `@EnvironmentObject var coordinator: HostingCoordinator`
- `LoginView.swift`, `LoginViewModel.swift`, `ForgotPasswordView.swift`
- `OnboardingCoordinatorView.swift`
- `TabBarCoordinatorView.swift`
- `FontExtensions.swift`, `ViewModifiers.swift`

## Migration from UIKit

When porting a UIKit module to SwiftUI:

1. **ViewModel**: Usually minimal changes, add `@MainActor` and use `@Published` instead of `CurrentValueSubject`
2. **Coordinator**: Biggest change - use `@Published` navigation state instead of `UINavigationController`
3. **View**: Complete rewrite using SwiftUI declarative syntax
4. **Services**: No changes - can be shared between UIKit and SwiftUI

## Testing

Coordinators and ViewModels can be tested similarly to UIKit:

```swift
@MainActor
final class LoginViewModelTests: XCTestCase {
    func testLoginSuccess() async {
        let viewModel = LoginViewModel()
        viewModel.email = "test@example.com"
        viewModel.password = "password"

        var didComplete = false
        viewModel.login { success in
            didComplete = success
        }

        XCTAssertTrue(didComplete)
    }
}
```

## Additional Resources

- [SwiftUI Navigation](https://developer.apple.com/documentation/swiftui/navigation)
- [Coordinator Pattern in SwiftUI](https://www.hackingwithswift.com/articles/216/complete-guide-to-navigationstack)
- [MVVM in SwiftUI](https://www.swiftbysundell.com/articles/mvvm-in-swift/)
