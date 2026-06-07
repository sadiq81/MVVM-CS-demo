# MVVM-CS Architecture for iOS: Part 2 Bridging UIKit and SwiftUI

**Tommy Sadiq Hinrichsen** | [@tommysadiqhinrichsen](https://medium.com/@tommysadiqhinrichsen)

---

In [Part 1](https://medium.com/@tommysadiqhinrichsen/building-scalable-ios-apps-a-modern-mvvm-coordinator-architecture-with-service-dependency-7ecf18c269ac) we built a full iOS app with MVVM-CS and pure UIKit, coordinators on top of `UINavigationController`, view models publishing through Combine, storyboard-based view controllers, all of it stitched together with dependency injection.

That architecture holds up. It scales. But sooner or later you want to write SwiftUI, and then a question lands on the table: **how do you bring SwiftUI views into a UIKit navigation stack while keeping the coordinator layer you already have?**

That is exactly what the Mixed app (`customerapp-Mixed`) solves. It keeps everything from Part 1, the UIKit lifecycle, the navigation stack, the coordinator tree. It swaps out just the view layer. Every `UIViewController` becomes a SwiftUI `View` wrapped in `UIHostingController`. Screen by screen, switch between UIKit or SwiftUI depending on the task at hand.

## The Bridge Architecture

Three pieces of Apple's UI stack come together in the Mixed app:

1. **UIKit lifecycle** `AppDelegate` still runs the show at startup
2. **UIKit navigation** `UINavigationController` and `UITabBarController` still own the view hierarchy
3. **SwiftUI views** every viewcontroller is replacted with a `View`, hosted inside a `UIHostingController`

The entry point hasn't changed at all from Part 1:

```swift
@main
final class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var coordinator: AppCoordinator?

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        self.window = UIWindow(frame: UIScreen.main.bounds)
        self.coordinator = AppCoordinator(window: self.window!)
        try? self.coordinator?.start()
        return true
    }
}
```

`AppCoordinator` creates the window, builds the coordinator tree and handles top-level transitions. Identical to the UIKit app. The differences only show up once child coordinators start presenting views.

## HostingCoordinator: The Key Bridge

The whole Mixed architecture is made possible by one new class: `HostingCoordinator`. We need it because SwiftUI still doesn't let you use protocols as environment objects, so we wrap the coordinator in a concrete `ObservableObject` instead.

`HostingCoordinator` takes any `CoordinatorType` and exposes its `transition(to:)` method through `@EnvironmentObject` injection. That one wrapper is enough for SwiftUI views to trigger UIKit-style navigation without ever touching `UINavigationController`, `UITabBarController`, `UIHostingController`, or the coordinator pattern itself. Separation of concerns stays clean.

From a SwiftUI view, kicking off a navigation looks like this:

```swift
struct MoreView: View {

    @EnvironmentObject
    private var coordinator: HostingCoordinator

    var body: some View {
        List {
            Button {
                try? self.coordinator.transition(to: MoreTransition.profile)
            } label: {
                Text("Profile")
            }
        }
    }
}
```

The view has no idea that behind that call, a UIKit coordinator is about to create a `UIHostingController` and push it onto a `UINavigationController`. All it does is ask for a transition by name.

On the coordinator side, the wiring is just as simple. Every coordinator wraps its SwiftUI view in a `HostingCoordinator` environment object and hands it off to `UIHostingController`:

```swift
func start() throws {
    let moreView = MoreView()
        .environmentObject(HostingCoordinator(coordinator: self))
    let controller = UIHostingController(rootView: moreView)
    self.navigationController?.setViewControllers([controller], animated: false)
}
```

You'll see this pattern everywhere in the Mixed app. The coordinator holds a weak reference to the navigation controller. The SwiftUI view manages its own state. `HostingCoordinator` sits in the middle, forwarding transition calls from the declarative world into the imperative one.

## Coordinators: Same Pattern, Different Views

Structurally, the coordinator hierarchy is unchanged from Part 1. `TabBarCoordinator` still creates a `UITabBarController` with one `UINavigationController` per tab:

```swift
final class TabBarCoordinator: NSObject, CoordinatorType {

    var baseController: UIViewController? { self.tabBarController }

    let tabBarController: UITabBarController
    weak var parent: (any CoordinatorType)?

    var children = NSHashTable<AnyObject>.weakObjects()

    init(parent: any CoordinatorType) {
        self.parent = parent
        self.tabBarController = UITabBarController()
        super.init()
    }

    func start() throws {
        // Dashboard tab
        let dashboardNavController = UINavigationController()
        let dashboardCoordinator = DashboardCoordinator(parent: self, navigationController: dashboardNavController)
        self.children.add(dashboardCoordinator)
        try dashboardCoordinator.start()

        // Search tab
        let searchNavController = UINavigationController()
        let searchCoordinator = SearchProductsCoordinator(parent: self, navigationController: searchNavController)
        self.children.add(searchCoordinator)
        try searchCoordinator.start()

        // ... Favorites tab, More tab follow the same pattern

        self.tabBarController.viewControllers = [
            dashboardNavController,
            searchNavController,
            favoritesNavController,
            moreNavController
        ]
    }
}
```

Each child coordinator gets a `UINavigationController` and pushes SwiftUI views wrapped in `UIHostingController`. The parent-child relationships, the `children` hash table with weak references, the `Completion` protocol for child-to-parent communication, none of that has changed.

## Transition Flow: From Tap to Push

Let's trace what happens when a user taps "Profile" in the More tab.

The SwiftUI `MoreView` calls `coordinator.transition(to: MoreTransition.profile)`. That call hits the `HostingCoordinator` (injected as `@EnvironmentObject`), which forwards it straight to the underlying `MoreCoordinator`. The coordinator matches on `.profile` and does what coordinators do:

```swift
func transition(to transition: MustacheServices.Transition) throws {
    if let transition = transition as? MoreTransition {
        switch transition {
            case .profile:
                let view = UserProfileView()
                    .environmentObject(HostingCoordinator(coordinator: self))
                let controller = UIHostingController(rootView: view)
                self.navigationController?.pushViewController(controller, animated: true)

            case .password:
                let view = PasswordView()
                    .environmentObject(HostingCoordinator(coordinator: self))
                let controller = UIHostingController(rootView: view)
                self.navigationController?.pushViewController(controller, animated: true)

            case .pop:
                self.navigationController?.popViewController(animated: true)
        }
    }
}
```

A new `UIHostingController` wrapping `UserProfileView` gets pushed onto the tab's navigation stack. The user sees a standard iOS push animation with a back button, because the navigation stack is real UIKit underneath.

Notice that the pushed view also gets a `HostingCoordinator` environment object pointing to the same coordinator. So `UserProfileView` can trigger further transitions too, navigate to the password screen, pop back, whatever `MoreTransition` defines.

Modal presentation works the same way. In the search coordinator, showing a filter screen just uses `present` instead of `push`:

```swift
case .filter(let filterType):
    let viewModel = Container.shared.filterSearchViewModel()
    viewModel.filterType = filterType
    let controller = FilterSearchView().hosted(by: self)
    
    let navController = UINavigationController(rootViewController: controller)
    self.navigationController?.present(navController, animated: true)
```

Push, present, pop, dismiss, standard `UINavigationController` operations. The SwiftUI views never need to know which one is being used.

## SwiftUI ViewModels: Direct ObservableObject

In the UIKit app, ViewModels hide behind protocols (`ProductSearchViewModelType`) and talk to the view layer through Combine publishers. For SwiftUI we skip that indirection. The ViewModel itself *is* the `ObservableObject`, with `@Published` properties that SwiftUI can observe directly:

```swift
@MainActor
final class ProductSearchViewModel: ObservableObject {

    @Published var searchText: String = ""
    @Published var searchResults: ProductSearchResult?
    @Published var isLoading = false
    @Published var selectedBrands: [any ProductFilter] = []
    @Published var selectedCategories: [any ProductFilter] = []

    ....

    @Injected(\.productService)
    private var productService: any ProductServiceType

    @Injected(\.filtersService)
    private var filterService: any FiltersServiceType

    private var cancellables = Set<AnyCancellable>()

    init() {
        self.$searchText
            .removeDuplicates()
            .debounce(for: .milliseconds(300), scheduler: DispatchQueue.main)
            .sink { [weak self] text in
                self?.internalSearchText = text
            }
            .store(in: &self.cancellables)

        // Subscribe to filter service changes...
    }
}
```

Services get resolved through `@Injected(\.productService)` from the Factory `Container` (more on that below). Combine subscriptions to service-level publishers happen internally, and the results bubble up as `@Published` properties that SwiftUI binds to.

On the view side, `@InjectedObject` resolves the ViewModel from the Container and manages its lifecycle the same way `@StateObject` would:

```swift
struct ProductSearchView: View {

    @EnvironmentObject
    private var coordinator: HostingCoordinator

    @InjectedObject(\.productSearchViewModel)
    private var viewModel

    var body: some View {
        VStack(spacing: 0) {
            searchAndFilterBar
            productList
        }
    }
}
```

No ViewState adapter, no extra layer between Combine and SwiftUI. The ViewModel owns its subscriptions, exposes `@Published` state, and SwiftUI watches it directly. When you eventually move to `@Observable` (iOS 17+), you swap out the `ObservableObject` conformance without touching views or coordinators.

## What Changes vs. Pure UIKit

Here's a clear breakdown of what stays and what moves when going from the UIKit app to the Mixed app:

**Unchanged:**
- `AppDelegate` entry point
- `UINavigationController` and `UITabBarController` navigation
- Coordinator hierarchy (parent-child, `NSHashTable` children, `Completion` protocol)
- Transition enums (`AppTransition`, `LoginTransition`, `MoreTransition`, etc.)
- Service layer and shared Container registrations
- Numbered module folder structure

**Changed:**
- `UIViewController` subclasses become SwiftUI `View` structs
- Storyboards and XIBs are gone entirely
- Coordinators push `UIHostingController` instead of `UIViewController`
- `HostingCoordinator` is injected as `@EnvironmentObject` for navigation
- ViewModels become direct `ObservableObject` classes with `@Published` properties

**Added:**
- `HostingCoordinator` environment object injection in every `start()` and `transition(to:)`
- SwiftUI ViewModel classes (direct `ObservableObject`, no adapter); the ones that are byte-identical with the pure SwiftUI app live in `Shared-SwiftUI/`

## Shared Code Architecture

The project splits shared code across two top-level folders, each mapped to a different set of targets through Xcode's file-system-synchronized groups:

```
Shared/                        # Compiled into ALL 3 apps (UIKit, Mixed, SwiftUI)
└── Sources/
    ├── Models/                #   Domain models (Product, User, Dashboard, …) + mocks
    ├── Services/              #   Protocol + implementation pairs (*ServiceType)
    │   └── Preview/           #   Preview service stubs for SwiftUI previews
    ├── Networking/            #   Endpoints, Requests, Responses
    ├── Extensions/            #   Foundation / UIKit / AppAuth / Factory extensions
    │   └── Factory/           #   Shared DI registrations (Container+Services)
    ├── DesignSystem/          #   Cross-app appearance, fonts, constants
    └── Modules/               #   Shared domain types (e.g. SegmentState)

Shared-SwiftUI/                # Compiled into Mixed + SwiftUI only
└── Sources/
    ├── DesignSystem/          #   SwiftUI font extensions, view modifiers
    └── Modules/               #   Byte-identical SwiftUI views + ViewModels
```

`Shared/` holds everything that doesn't depend on a particular UI flavour: models, services, networking, the cross-app design system, and the shared Factory `Container` service registrations. Every target compiles it (all six — Dev and Prod per app).

`Shared-SwiftUI/` holds the SwiftUI code that the Mixed and pure SwiftUI apps can compile *unchanged* — files that came out byte-for-byte identical, such as `VideoPlayerView`, `PinInputView`, `SecretView`, and a handful of presentation-only ViewModels. Views whose navigation wiring differs between the two apps (Mixed routes through `HostingCoordinator`, pure SwiftUI through the navigator — more on that in Part 3) stay in each app's own target. Xcode file membership, not symlinks, decides what compiles where.

The coordinator files barely change either. Compare `SearchProductsCoordinator.start()` from the UIKit app:

```swift
// UIKit: pushes a UIViewController loaded from storyboard
func start() throws {
    let controller = AppStoryboard.viewController(class: ProductSearchViewController.self)
    controller.coordinator = self
    self.navigationController?.setViewControllers([controller], animated: false)
}
```

With the Mixed version:

```swift
// Mixed: pushes a UIHostingController wrapping a SwiftUI view
func start() throws {
    let searchView = ProductSearchView()
        .environmentObject(HostingCoordinator(coordinator: self))
    let controller = UIHostingController(rootView: searchView)
    self.navigationController?.setViewControllers([controller], animated: false)
}
```

Three lines, same shape, different view technology. The navigation controller doesn't care what kind of `UIViewController` it's pushing.

## Dependency Injection: Factory Container

All apps use the **Factory** pattern from MustacheServices for dependency injection. Services live in shared `Container` extensions; ViewModels are registered per-app.

**Shared services** (compiled into all apps) in `Shared/Sources/Extensions/Factory/Container+Services.swift`:

```swift
extension Container {

    var loginService: Factory<any LoginServiceType> {
        self { LoginService() }
    }

    var dashboardService: Factory<any DashboardServiceType> {
        self { DashboardService() }
    }

    var productService: Factory<any ProductServiceType> {
        self { ProductService() }
    }

    // ...
}
```

**UIKit ViewModels** in `customerapp-UIKit/Sources/Extensions/Container/Container+ViewModels.swift`:

```swift
extension Container {

    var dashboardViewModelType: Factory<any DashboardViewModelType> {
        self { MainActor.assumeIsolated { DashboardViewModel() } }.shared
    }

    var favoritesViewModelType: Factory<any FavoritesViewModelType> {
        self { MainActor.assumeIsolated { FavoritesViewModel() } }.shared
    }
}
```

**SwiftUI ViewModels** in `customerapp-Mixed/Sources/Extensions/Factory/Container+ViewModels.swift`:

```swift
extension Container {

    var favoritesViewModel: Factory<FavoritesViewModel> {
        self { MainActor.assumeIsolated { FavoritesViewModel() } }.shared
    }

    var dashboardViewModel: Factory<DashboardViewModel> {
        self { MainActor.assumeIsolated { DashboardViewModel() } }.shared
    }
}
```

There's a deliberate difference here. UIKit ViewModel registrations use **protocol types** (`any DashboardViewModelType`). SwiftUI registrations use **concrete types** (`DashboardViewModel`), because `@InjectedObject` manages the lifecycle the way `@StateObject` does and SwiftUI can't observe a `some ObservableObject` behind an existential. ViewModels that need model data — a product detail screen, a PIN screen — register as a `ParameterFactory` instead, so the coordinator passes the value in at resolve time.

Two property wrappers handle all injection:
- `@Injected(\.productService)` for services (non-observable)
- `@InjectedObject(\.favoritesViewModel)` for SwiftUI `ObservableObject` ViewModels

## The App-Level Flow

To see how it all fits, here's the full navigation flow from app launch:

1. `AppDelegate` creates `AppCoordinator` with the window
2. `AppCoordinator.start()` wraps `SplashView` in `UIHostingController` and sets it as root
3. After splash, `AppCoordinator.transition(to: .splashCompleted)` checks auth state
4. If not logged in, `LoginCoordinator` gets a new `UINavigationController` and shows `LoginView` (SwiftUI) through `UIHostingController`
5. After login, `TabBarCoordinator` creates a `UITabBarController` with four `UINavigationController` tabs
6. Each tab coordinator wraps its root SwiftUI view in `UIHostingController` and puts it on its navigation controller

The cross-dissolve between flows uses plain UIKit animation:

```swift
    case .loginCompleted:
        guard self.onboardingService.onboardedCompleted(for: .login) == .completed else {
            try self.transition(to: AppTransition.onboarding)
            return
        }

        let tabBarCoordinator = TabBarCoordinator(parent: self)
        try tabBarCoordinator.start()
        self.children.add(tabBarCoordinator)

        UIView.transition(with: self.window, duration: 0.5, options: .transitionCrossDissolve) {
            self.window.rootViewController = tabBarCoordinator.tabBarController
        }
```

Pure UIKit animation code, in a coordinator that presents SwiftUI views. The two worlds coexist because the boundary is always `UIHostingController`.

## When to Use This Approach

The Mixed architecture makes sense when:

- You have an existing UIKit app and want to **adopt SwiftUI one screen at a time**
- You need UIKit-level control over navigation, custom transitions, coordinator-managed stacks
- Your team is picking up SwiftUI and wants to **replace screens gradually**

If you're starting from scratch with no UIKit to migrate, wait for our next Part 3 and go pure SwiftUI from day one.

The beauty of the Mixed approach is that it's not a permanent destination. It's a **bridge**. Every screen you build in SwiftUI for the Mixed app is one screen closer to a pure SwiftUI app, and because the views only talk to `HostingCoordinator`, they'll work unchanged when you get there.

---

## Up Next: Part 3 Pure SwiftUI

In Part 3 we drop UIKit entirely. No `AppDelegate`, no `UINavigationController`, no `UIHostingController`. The `@main` entry point becomes a SwiftUI `App` struct, and navigation moves to the **NavigatorUI** library: each flow is a `ManagedNavigationStack`, each module declares a `NavigationDestination` enum that maps a route to a view and a presentation `method` (push or sheet), and views talk to an injected `Navigator` from the environment instead of a coordinator object.

The shared code keeps doing its job: models, services, networking, the design system, and the Factory `Container` service registrations live in `Shared/` and compile into all three apps. The SwiftUI files that came out byte-identical between Mixed and pure SwiftUI live in `Shared-SwiftUI/` and compile into both. The views whose only difference is *how* they trigger navigation stay per-app — that difference is exactly what Part 3 is about.

The complete source code for all three apps is available on [GitHub](https://github.com/sadiq81/MVVM-CS-demo).

---

*This is Part 2 of a 3-part series on MVVM-CS architecture for iOS. [Part 1](https://medium.com/@tommysadiqhinrichsen/building-scalable-ios-apps-a-modern-mvvm-coordinator-architecture-with-service-dependency-7ecf18c269ac) covers the pure UIKit approach. Part 3 covers pure SwiftUI.*
