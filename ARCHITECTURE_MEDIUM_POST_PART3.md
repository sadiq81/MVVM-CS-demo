# MVVM-CS Architecture for iOS -- Part 3: Pure SwiftUI

## Completing the Migration: How MVVM-CS Translates to a Fully Declarative SwiftUI App

---

## Table of Contents

1. [Introduction](#introduction)
2. [The Pure SwiftUI Entry Point](#the-pure-swiftui-entry-point)
3. [NavigatorUI: Navigation Without Coordinator Objects](#navigatorui-navigation-without-coordinator-objects)
4. [Destination Enums: Routes That Render Themselves](#destination-enums-routes-that-render-themselves)
5. [The App-Level Flow: Screens and Events](#the-app-level-flow-screens-and-events)
6. [Views Own Navigation; ViewModels Stay Pure](#views-own-navigation-viewmodels-stay-pure)
7. [SwiftUI ViewModels: Direct ObservableObject](#swiftui-viewmodels-direct-observableobject)
8. [Tab-Based Navigation](#tab-based-navigation)
9. [The Full Progression: UIKit to Mixed to SwiftUI](#the-full-progression-uikit-to-mixed-to-swiftui)
10. [Conclusion: Three Apps, One Architecture](#conclusion-three-apps-one-architecture)

---

## Introduction

In [Part 1](https://medium.com/@tommysadiqhinrichsen/building-scalable-ios-apps-a-modern-mvvm-coordinator-architecture-with-service-dependency-7ecf18c269ac) we built a production-grade iOS app with MVVM-CS and pure UIKit. Coordinators owned `UINavigationController` instances, ViewModels talked through Combine publishers, and views were `UIViewController` subclasses wired to storyboards.

[Part 2](https://medium.com/@tommysadiqhinrichsen) introduced the Mixed app -- UIKit coordinators still ran navigation via `UINavigationController`, but the views themselves were SwiftUI, hosted through `UIHostingController`. The `HostingCoordinator` bridge made it possible without SwiftUI views ever knowing they lived inside UIKit.

Now we finish the journey. The pure SwiftUI app drops UIKit entirely. No `AppDelegate`, no `SceneDelegate`, no `UINavigationController`, no `UIHostingController`. Navigation is handled declaratively with the **NavigatorUI** library: flows are wrapped in a `ManagedNavigationStack`, each module declares a `NavigationDestination` enum that maps a route to a view *and* its presentation style, and views reach navigation through an injected `Navigator` from the environment.

Here's the honest part of the story, though. In Part 2 I said the same SwiftUI view files compile into both the Mixed and the pure SwiftUI app. That's true for the views that don't navigate -- a `VideoPlayerView`, a `PinInputView`, a presentation-only `SecretView`. But a screen that *triggers* navigation can't be identical across the two apps, because the navigation mechanism is different: the Mixed app sends transitions through `HostingCoordinator`, the pure SwiftUI app sends destinations through `Navigator`. So the byte-identical files live in `Shared-SwiftUI/` and compile into both apps, while the navigating views stay in each app's own target. Same view, same layout, different last mile. This article is about that last mile.

---

## The Pure SwiftUI Entry Point

The most obvious change is the app's front door. The UIKit and Mixed apps need an `AppDelegate`. The pure SwiftUI app replaces all of it with `@main`:

```swift
@main
struct CustomerApp: App {

    init() {
        // DI Container
        AppContainer.configure()

        // Custom fonts — swizzle UIFont.preferredFont to use Montserrat
        Appearance.configure()

        // Firebase
        // FirebaseApp.configure()
    }

    var body: some Scene {
        WindowGroup {
            AppRootView()
        }
    }
}
```

A few things worth noting:

- **No UIKit lifecycle code.** No `application(_:didFinishLaunchingWithOptions:)`, no window setup, no root view controller assignment. The container and appearance setup that used to happen in `AppDelegate` now happens in the `App` struct's `init`.
- **`AppRootView` is the whole app.** It decides which flow is on screen and listens for app-level navigation events. No root coordinator object is created here.

The interesting question is: with no coordinator objects and no `UINavigationController`, what actually drives navigation?

---

## NavigatorUI: Navigation Without Coordinator Objects

In the UIKit and Mixed apps, every push, pop, and present went through a coordinator -- an `NSObject` conforming to `CoordinatorType`, owning a `UINavigationController`. The pure SwiftUI app doesn't have those. Instead it leans on **NavigatorUI**, a small library (from the author of Factory) that gives SwiftUI a coordinator-like navigation model without leaving the declarative world.

Two pieces do the heavy lifting:

1. **`ManagedNavigationStack`** wraps a flow and owns the underlying `NavigationStack` and its path. You give it a `scene` name; it manages the rest.
2. **`Navigator`**, injected via `@Environment(\.navigator)`, is the handle a view uses to navigate. Calling `navigator.navigate(to:)` pushes or presents a destination; calling `navigator.send(_:)` broadcasts an event up the tree.

A flow root looks like this:

```swift
ManagedNavigationStack(scene: "more") {
    MoreView()
}
```

And a view that wants to navigate just asks the environment for the navigator:

```swift
struct SomeView: View {

    @Environment(\.navigator)
    private var navigator: Navigator

    var body: some View {
        Button("Profile") {
            self.navigator.navigate(to: MoreDestination.profile)
        }
    }
}
```

No `NavigationLink`, no manually managed `NavigationPath`, no concrete coordinator type referenced from the view. The navigator is the seam between the view and the navigation stack, the same role `HostingCoordinator` played in the Mixed app.

---

## Destination Enums: Routes That Render Themselves

In the UIKit app, a coordinator's `transition(to:)` switched over a `Transition` enum and built the destination view controller inline. In the SwiftUI app, that responsibility moves into a `NavigationDestination` enum -- each module owns one, and the enum knows both *what view* a route renders and *how* it should be presented:

```swift
@MainActor
enum MoreDestination: NavigationDestination {

    case profile
    case password
    case secureContent
    case countryPicker(CountrySelectionMode)
    case webview(URL)
    case addressSearch
    case validateAge

    var body: some View {
        switch self {
            case .profile:          UserProfileView()
            case .password:         PasswordView()
            case .secureContent:    SecretView()
            case .countryPicker(let mode): CountryPickerView(mode: mode)
            case .webview(let url):
                SafariView(url: url).ignoresSafeArea()
            case .addressSearch:    AddressSearchView()
            case .validateAge:      OIDAuthorizationView()
        }
    }

    var method: NavigationMethod {
        switch self {
            case .profile, .password, .secureContent:
                return .push
            case .countryPicker, .webview, .validateAge, .addressSearch:
                return .sheet
        }
    }
}
```

Two things make this pattern pull its weight:

- **`var body`** -- the destination *is* a view factory. NavigatorUI calls into it to build the screen when a route is navigated to. There's no separate `.navigationDestination(for:)` switch to keep in sync; the enum is the single source of truth.
- **`var method`** -- push or sheet is a property of the route, declared right next to it. The More flow pushes `.profile` and `.password`, but presents `.countryPicker` and `.webview` as sheets. Changing how a screen appears is a one-line edit in the enum, not a change at every call site.

Type safety stays at the module level. `MoreView` navigates with `MoreDestination` values, `FavoritesView` with `FavoritesDestination`. The compiler won't let you push a More route from the Favorites flow.

Routes that carry data are just enum cases with associated values, and the `body` resolves the right ViewModel as it builds the screen:

```swift
@MainActor
enum FavoritesDestination: NavigationDestination {

    case details(ProductModel)

    var body: some View {
        switch self {
            case .details(let product):
                let viewModel = Container.shared.productDetailViewModel(product)
                ProductDetailView(viewModel: viewModel)
        }
    }

    var method: NavigationMethod { .push }
}
```

`Container.shared.productDetailViewModel(product)` is a `ParameterFactory` -- the model is passed in at resolve time. No casting, no resolve-then-mutate dance; the route value flows straight into the ViewModel.

---

## The App-Level Flow: Screens and Events

App-level navigation -- splash → login → onboarding → tab bar -- isn't a push/pop stack, so it doesn't belong to a `ManagedNavigationStack`. It's a flow switch, and `AppRootView` owns it with a plain `@State`:

```swift
struct AppRootView: View {

    @State private var screen: AppScreen = .splash

    // services injected via @Injected(\.…) …

    var body: some View {
        ZStack {
            Color(Colors.Background.default.color).ignoresSafeArea()

            switch self.screen {
                case .splash:
                    ManagedNavigationStack(scene: "splash") { SplashView() }
                        .transition(.opacity)
                case .login:
                    ManagedNavigationStack(scene: "login") { LoginView() }
                        .transition(.move(edge: .trailing))
                case .onboarding:
                    OnboardingView()
                        .transition(.move(edge: .trailing))
                case .tabBar:
                    TabBarView()
                        .transition(.move(edge: .trailing))
            }
        }
        .animation(.easeInOut, value: self.screen)
        .onNavigationReceive { (event: AppEvent, _) in
            self.handleEvent(event)
            return .auto
        }
    }
}
```

Two enums keep "what happened" separate from "what to show":

```swift
// What to display
enum AppScreen: Equatable {
    case splash
    case login
    case onboarding
    case tabBar
}

// What happened
enum AppEvent: Hashable {
    case splashCompleted
    case loginCompleted
    case onboardingCompleted
    case logout
}
```

A view broadcasts an event with `navigator.send(...)`. `AppRootView` catches it through `.onNavigationReceive` and maps it to the next screen -- the same decision logic the UIKit `AppCoordinator` ran, just expressed as state instead of `window.rootViewController` assignment:

```swift
private func handleEvent(_ event: AppEvent) {
    switch event {
        case .splashCompleted:
            if self.userService.user.exists {
                self.screen = self.onboardingService.onboardedCompleted(for: .login) == .completed
                    ? .tabBar : .onboarding
            } else {
                self.screen = .login
            }
        case .loginCompleted:
            self.screen = self.onboardingService.onboardedCompleted(for: .login) == .completed
                ? .tabBar : .onboarding
        case .onboardingCompleted:
            self.screen = .tabBar
        case .logout:
            self.handleLogout()
    }
}
```

The splash screen, for instance, simply announces it's done:

```swift
self.navigator.send(AppEvent.splashCompleted)
```

The `ZStack` plus `.transition()` modifiers give us animated switches between flows -- in UIKit this would have meant a custom `UIViewControllerAnimatedTransitioning`. Here it's two lines.

---

## Views Own Navigation; ViewModels Stay Pure

A deliberate rule in the pure SwiftUI app: **ViewModels never touch navigation.** No `Navigator`, no `…Destination`, no `AppEvent` — a ViewModel does business logic and exposes plain observable state. Navigation lives entirely in the Views (which hold the `Navigator`) and the `Navigator` itself. Three cases cover everything.

**1. Pure navigation** — a control that always goes to the same place. The View calls the navigator inline; there's nothing for the ViewModel to do:

```swift
Button("Profile") {
    self.navigator.navigate(to: MoreDestination.profile)   // push or sheet, per Destination.method
}
```

**2. Navigation that follows async work** (login succeeded, signup, onboarding finished, logout). The ViewModel flips a plain flag; the View observes it and fires the event:

```swift
// ViewModel — no navigation types at all
@Published var didLogin = false
func login() { Task { try await loginService.login(...); self.didLogin = true } }

// View
.onChange(of: self.viewModel.didLogin) { _, ok in
    if ok { self.navigator.send(AppEvent.loginCompleted) }
}
```

**3. Navigation whose destination is *decided* by business logic.** The ViewModel returns a **domain result** (still no navigation types); the View maps that result to a route. The "secret" screen, for instance, needs a PIN flow unless the data is already unlocked:

```swift
// ViewModel
enum SecureContentRoute { case secret, validate, enroll(Data) }
@Published var secureContentRoute: SecureContentRoute?
func requestSecureContent() { /* inspect secure storage, then set the route */ }

// View
.onReceive(self.viewModel.$secureContentRoute) { route in
    guard let route else { return }
    switch route {
        case .secret:           self.navigator.navigate(to: MoreDestination.secureContent)
        case .validate:         self.navigator.navigate(to: PinDestination.validate)
        case .enroll(let data): self.navigator.navigate(to: PinDestination.enroll(data))
    }
}
```

The ViewModel decides *what happened* (a result); the View decides *where that leads* (a route). The ViewModel has zero knowledge of the navigation graph — which keeps it trivially testable and reusable, and means the same business logic could drive a different navigation shape without changing the ViewModel at all.

---

## SwiftUI ViewModels: Direct ObservableObject

Aside from that navigation property, SwiftUI ViewModels follow the same shape as in the Mixed app. In UIKit, ViewModels hide behind a protocol (`ProductSearchViewModelType`) and expose Combine publishers; view controllers subscribe in `configureBindings()`. For SwiftUI we take the shorter path -- the ViewModel itself is the `ObservableObject`, with `@Published` properties SwiftUI observes natively:

```swift
@MainActor
final class ProductSearchViewModel: ObservableObject {

    @Published var searchText: String = ""
    @Published var searchResults: ProductSearchResult?
    @Published var isLoading = false
    @Published var selectedBrands: [any ProductFilter] = []
    @Published var selectedCategories: [any ProductFilter] = []

    @Injected(\.productService)
    private var productService: any ProductServiceType

    @Injected(\.filtersService)
    private var filterService: any FiltersServiceType

    private var cancellables = Set<AnyCancellable>()

    init() {
        self.$searchText
            .removeDuplicates()
            .debounce(for: .milliseconds(300), scheduler: DispatchQueue.main)
            .sink { [weak self] text in self?.internalSearchText = text }
            .store(in: &self.cancellables)

        // Subscribe to filter service Combine publishers internally…
    }
}
```

Services come in through `@Injected(\.productService)` from the Factory `Container`. Combine subscriptions to service-level publishers happen inside the ViewModel; results surface as `@Published` properties. The view sees none of the plumbing:

```swift
struct ProductSearchView: View {

    @Environment(\.navigator)
    private var navigator: Navigator

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

`@InjectedObject(\.productSearchViewModel)` resolves the ViewModel from the `Container` and manages its lifecycle the way `@StateObject` would. The registrations live in `customerapp-SwiftUI/Sources/Extensions/Factory/Container+ViewModels.swift`:

```swift
extension Container {

    var productSearchViewModel: Factory<ProductSearchViewModel> {
        self { MainActor.assumeIsolated { ProductSearchViewModel() } }.shared
    }

    // ViewModels that need context register as a ParameterFactory
    var productDetailViewModel: ParameterFactory<ProductModel, ProductDetailViewModel> {
        self { product in
            MainActor.assumeIsolated { ProductDetailViewModel(product: product) }
        }.shared
    }
}
```

Two kinds of registration, one rule of thumb. A zero-argument `Factory` for ViewModels that stand on their own; a `ParameterFactory` for the ones that need data -- the product on a detail screen, the secret payload on a PIN screen. The route's associated value flows straight into the ViewModel at resolve time, which is why `FavoritesDestination.details` could call `Container.shared.productDetailViewModel(product)` directly.

When you eventually move to `@Observable` (iOS 17+), you swap the `ObservableObject` conformance and the rest stays untouched.

---

## Tab-Based Navigation

`TabBarView` takes over from `UITabBarController`. Each tab gets its own `ManagedNavigationStack`, so each tab owns an independent navigation stack -- exactly like UIKit where each tab had its own `UINavigationController`:

```swift
struct TabBarView: View {

    @State private var selectedTab: TabBarIndex = .dashboard

    enum TabBarIndex: Hashable {
        case dashboard, search, favorites, more
    }

    var body: some View {
        TabView(selection: self.$selectedTab) {
            ManagedNavigationStack(scene: "dashboard") { DashboardView() }
                .tabItem { Label(Strings.Tabbar.dashboard, systemImage: Images.System.dashboard) }
                .tag(TabBarIndex.dashboard)

            ManagedNavigationStack(scene: "search") { ProductSearchView() }
                .tabItem { Label(Strings.Tabbar.search, systemImage: Images.System.search) }
                .tag(TabBarIndex.search)

            ManagedNavigationStack(scene: "favorites") { FavoritesView() }
                .tabItem { Label(Strings.Tabbar.entities, systemImage: Images.System.favorites) }
                .tag(TabBarIndex.favorites)

            ManagedNavigationStack(scene: "more") { MoreView() }
                .tabItem { Label(Strings.Tabbar.more, systemImage: Images.System.more) }
                .tag(TabBarIndex.more)
        }
        .accentColor(Color(Colors.Foreground.brand.color))
        .onNavigationReceive(assign: self.$selectedTab)
    }
}
```

Two NavigatorUI touches make this more than a plain `TabView`:

- Each tab's content is a `ManagedNavigationStack` with its own `scene`, so pushing a detail view in Search leaves the Favorites stack untouched.
- `.onNavigationReceive(assign: self.$selectedTab)` lets *any* part of the app switch tabs by sending a `TabBarIndex` -- the declarative equivalent of `tabBarController.selectedIndex = …`.

---

## The Full Progression: UIKit to Mixed to SwiftUI

Here's how each piece of the architecture translates across all three apps:

| Component | UIKit | Mixed | SwiftUI |
|-----------|-------|-------|---------|
| **Entry Point** | `AppDelegate` | `AppDelegate` | `@main App` struct |
| **Navigation Stack** | `UINavigationController` | `UINavigationController` | `ManagedNavigationStack` (NavigatorUI) |
| **Navigation owner** | `CoordinatorType` (NSObject) | `CoordinatorType` (NSObject) | `Navigator` via `@Environment(\.navigator)` |
| **Push a View** | `nav.pushViewController(vc)` | `nav.pushViewController(UIHostingController(rootView:))` | `navigator.navigate(to:)` + destination `.method = .push` |
| **Pop** | `nav.popViewController(animated:)` | Same | navigator dismiss / back |
| **Present Modal** | `vc.present(modal)` | `vc.present(UIHostingController(rootView:))` | destination `.method = .sheet` |
| **Route Definition** | Implicit (any ViewController) | Implicit (any UIHostingController) | `NavigationDestination` enum with `body` + `method` |
| **View Implementation** | `UIViewController` + Storyboard | SwiftUI `View` in `UIHostingController` | SwiftUI `View` |
| **View → navigation** | Delegate or coordinator | `@EnvironmentObject HostingCoordinator` | `@Environment(\.navigator)` in the View; ViewModel exposes only domain state |
| **Flow switching** | `window.rootViewController` | `window.rootViewController` | `@State screen` + `.onNavigationReceive` |
| **Tab Bar** | `UITabBarController` | `UITabBarController` | `TabView` of `ManagedNavigationStack`s |
| **Transitions / Events** | Module `Transition` enums | Same | `NavigationDestination` + `AppEvent` |
| **ViewModel** | `*ViewModelType` protocol + Combine | Direct `ObservableObject` with `@Published` | Direct `ObservableObject` with `@Published` |
| **DI** | `@Injected(\.service)` via Factory Container | Same (+ `@InjectedObject`) | Same (+ `ParameterFactory` for VMs with data) |

The progression makes sense once you see it laid out:

1. **UIKit** -- coordinators are fully imperative. They own UIKit objects and call UIKit APIs directly.
2. **Mixed** -- coordinators are still imperative, but they wrap SwiftUI views in `UIHostingController` before pushing. The views themselves are declarative.
3. **SwiftUI** -- there are no coordinator objects. NavigatorUI's `Navigator` plays the coordinator role, `NavigationDestination` enums own the route-to-view mapping and presentation style, and app-level flow is plain SwiftUI state driven by `AppEvent`s.

The business logic -- services, models, networking, the design system, Factory `Container` service registrations -- **stays shared** across all three apps from `Shared/`. The SwiftUI files that came out byte-identical between Mixed and pure SwiftUI live in `Shared-SwiftUI/` and compile into both. When the navigation technology changes, only the navigation layer changes. Everything underneath stays stable.

---

## Conclusion: Three Apps, One Architecture

This three-part series has walked through a complete iOS architecture that works at every point on the UIKit-to-SwiftUI spectrum.

**Part 1** laid the groundwork: MVVM for separating view logic from business logic, Coordinators for pulling navigation into dedicated objects, Services for managing data access through dependency injection. These patterns have been running in 15+ production apps with over a million daily users.

**Part 2** showed you don't have to pick sides. `HostingCoordinator` lets you write SwiftUI views and host them in a UIKit navigation stack -- keeping your coordinator infrastructure intact while modernizing views one screen at a time.

**Part 3** (this article) finished the picture. In a pure SwiftUI app, the coordinator objects disappear entirely. NavigatorUI's `Navigator` becomes the navigation seam, `ManagedNavigationStack` owns each flow's stack, and every module declares a `NavigationDestination` enum that maps routes to views and to a push-or-sheet `method`. App-level flow is plain SwiftUI state driven by `AppEvent`s. No `UINavigationController`, no `UIHostingController`, no hand-rolled `NavigationPath` plumbing.

The thing I want you to take away isn't the specific library -- it's that the seam never moved. UIKit had `CoordinatorType`, Mixed had `HostingCoordinator`, SwiftUI has `Navigator`. In all three, the view says "take me to this route" and something else decides how. That consistency is what let the same models, services, and a large slice of the SwiftUI layer compile unchanged across all three apps.

The shared code lives in two folders:

- **`Shared/`** -- models, services, networking, the cross-app design system, Foundation/UIKit/AppAuth extensions, and the Factory `Container` *service* registrations (`Container+Services`). Compiled into all three apps (all six targets).
- **`Shared-SwiftUI/`** -- the SwiftUI views and ViewModels that are byte-identical between the Mixed and pure SwiftUI apps (e.g. `VideoPlayerView`, `PinInputView`, `SecretView`). Compiled into Mixed and SwiftUI, excluded from UIKit.

Views whose only difference is *how* they trigger navigation stay in each app's target, and Xcode's file-system-synchronized groups -- not symlinks -- decide what compiles where.

Dependency injection runs on the **Factory** pattern throughout. Services register as `Factory<any ServiceType>` in shared `Container` extensions. SwiftUI ViewModels register per-app as `Factory<ConcreteViewModel>` (or `ParameterFactory<Input, ConcreteViewModel>` when they need data) and resolve through `@InjectedObject(\.viewModel)`, which acts like `@StateObject`. UIKit ViewModels use protocol-typed `Factory<any ViewModelType>` registrations. The same `@Injected(\.service)` keypath syntax works identically everywhere.

Starting fresh today? Go pure SwiftUI. Maintaining an existing UIKit app? The Mixed approach gives you a migration path. Need to support both during the transition? This architecture handles it while sharing nearly everything but the last mile of navigation.

The complete source for all three apps is on [GitHub](https://github.com/sadiq81/MVVM-CS-demo).

---

*Tommy Sadiq Hinrichsen ([@tommysadiqhinrichsen](https://medium.com/@tommysadiqhinrichsen)) is a senior iOS developer and the creator of MustacheKit. This is Part 3 of a 3-part series on MVVM-CS architecture for iOS.*
