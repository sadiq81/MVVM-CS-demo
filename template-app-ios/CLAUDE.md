# Template App iOS

3-app iOS showcase of MVVM-CS architecture: UIKit, Mixed (UIKit+SwiftUI), and Pure SwiftUI.

---

## Project Essentials

- **Project**: Always use `customerapp.xcodeproj`
- **File sync**: `PBXFileSystemSynchronizedRootGroup` — files on disk auto-sync to Xcode. No manual pbxproj edits.
- **Build**: `xcodebuild -project customerapp.xcodeproj -scheme UIKit-Development -destination 'generic/platform=iOS Simulator' build`

---

## Targets & Schemes

| App | Dev Scheme | Prod Scheme |
|-----|-----------|-------------|
| UIKit | `UIKit-Development` | `UIKit-Production` |
| Mixed | `Mixed-Development` | `Mixed-Production` |
| SwiftUI | `SwiftUI-Development` | `SwiftUI-Production` |

Development schemes point to `localhost:8080`. Production schemes point to the production backend.

---

## Project Structure

```
template-app-ios/
  Config/                         # Shared xcconfig base files
    Shared.xcconfig
    Shared-Development.xcconfig
    Shared-Production.xcconfig
  Resources/                      # Shared assets (all 6 targets)
    Images/, Fonts/, Localization/, Video/, Colors/, Files/
  customerapp-Shared/             # Shared code (all 6 targets)
    Common/
      Container/                  # Factory DI registrations (Container+Services, Container+ViewModels)
      Extensions/
      Models/                     # Plain data structs with +Mock files
      Modules/                    # Shared module code (SplashScreenViewModelType, Environment)
      Networking/                 # Endpoints, Requests, Responses
      Services/                   # Protocol + Implementation pairs (*ServiceType)
        Preview/                  # Preview service stubs for SwiftUI previews
    SwiftUI/                      # Shared SwiftUI views + ViewModels (used by Mixed + SwiftUI apps)
      DesignSystem/
      Extensions/
      Modules/                    # 010_Splash through 080_More
  customerapp-UIKit/              # App 1: Pure UIKit
    Sources/
      DesignSystem/               # UIKit styling (Appearance, Colors, Fonts, Spacing)
      Extensions/
        Container/                # Container+ViewModels (UIKit-specific)
      Modules/                    # 001_Application through 090_Pin
      Networking/                 # (legacy — being migrated to Shared)
      Services/                   # (legacy — being migrated to Shared)
    Resources/
  customerapp-Mixed/              # App 2: UIKit + SwiftUI
    Sources/
      Extensions/
      Modules/                    # Coordinators only (views symlinked from SwiftUI)
  customerapp-SwiftUI/            # App 3: Pure SwiftUI
    Sources/
      Extensions/
      Modules/                    # App entry, coordinators, routing
```

Each module follows: `Routing/` | `ViewModel/` | `Views/` (or `ViewController/`) | `Cell/` | `View/`

---

## Architecture Quick Reference

```
Coordinator  →  creates VC/View + injects VM via Container
 ViewController/View  →  binds to VM publishers, triggers coordinator transitions
 ViewModel  →  transforms service data, exposes via @Published / Combine
Service  →  owns state, calls network
```

**Data flows down** (Service → VM → View). **Events flow up** (View → VM/Coordinator).

---

## The 3 App Approaches

### 1. customerapp-UIKit (Pure UIKit)
- **Entry point**: `AppDelegate`
- **Navigation**: `UINavigationController` managed by `CoordinatorType` (MustacheKit)
- **Views**: `UIViewController` subclasses with storyboards and XIBs
- **DI**: `@Injected` in VMs, Factory `Container+ViewModels` for VM registration

### 2. customerapp-Mixed (UIKit + SwiftUI)
- **Entry point**: `AppDelegate` (UIKit lifecycle)
- **Navigation**: `UINavigationController` managed by coordinators
- **Views**: SwiftUI views via `UIHostingController` using `HostingCoordinator` (MustacheServices)
- **Symlinks**: File-level symlinks to `customerapp-SwiftUI/` for shared SwiftUI views

### 3. customerapp-SwiftUI (Pure SwiftUI)
- **Entry point**: `@main` App struct (`SwiftUIApp.swift`)
- **Navigation**: `NavigationStack` with path-based routing
- **Coordinators**: `SwiftUICoordinatorType` with `@Published` navigation state

---

## Key Patterns

| Pattern | Convention |
|---------|-----------|
| ViewModel files (UIKit) | Protocol + Implementation: `{Name}ViewModelType.swift` |
| ViewModel files (SwiftUI) | Concrete class: `{Name}ViewModel.swift` |
| Service files | Protocol + Implementation: `{Name}ServiceType.swift` |
| Publisher exposure | Protocol: `var fooPublisher: AnyPublisher`. Implementation: `@Published var foo` |
| DI in Views/VMs | `@Injected(\.service)` for services, `@InjectedObject(\.viewModel)` for observable VMs |
| DI in Services | `@Injected(\.network)` |
| Container registration | `extension Container { var foo: Factory<FooType> { self { Foo() } } }` |
| Navigation | `try? self.coordinator.transition(to: SomeTransition.case(...))` |
| Assets | SwiftGen: `Images.`, `Colors.`, `FontFamily.`, `Strings.`, `Files.` |
| Coordinator parent | Always `weak var parent: (any CoordinatorType)?` |

---

## Dependency Injection (Factory / Container)

Uses **Factory** pattern from MustacheServices via `Container` extensions:

**Registration** — in `Container+Services.swift` (shared) and `Container+ViewModels.swift` (per-app):
```swift
extension Container {
    var productService: Factory<any ProductServiceType> {
        self { ProductService() }
    }
    var productsViewModel: Factory<ProductsViewModel> {
        self { MainActor.assumeIsolated { ProductsViewModel() } }
    }
}
```

**Injection** — via property wrappers:
```swift
@Injected(\.productService) private var productService      // non-observable
@InjectedObject(\.productsViewModel) private var viewModel   // SwiftUI ObservableObject
```

### Injecting ViewModels with Model Data (Resolve-Set Pattern)

When a ViewModel needs model data (e.g., product detail screen), resolve from Container, cast to concrete type, set the model:

```swift
// In coordinator:
case .details(let product):
    let vm = Container.shared.productDetailViewModel() as? ProductDetailViewModel
    vm?.product = product
    // push view/controller
```

The protocol declares the model as getter-only. The concrete class has getter+setter backed by `@Published`.

---

## Navigation Flow (all apps)

Splash → Login → Onboarding → TabBar → (Dashboard, Search, Products, More)

Transitions: `.splashCompleted`, `.login`, `.loginCompleted`, `.onboarding`, `.onboardingCompleted`

---

## Import Organization

Three groups, separated by blank lines, alphabetical within each:

```swift
import Combine        // 1. Apple frameworks
import Foundation
import UIKit

import MustacheServices       // 2. Mustache modules

import SomeDependency  // 3. Third-party / SPM
```

---

## ViewController Lifecycle (UIKit)

```swift
override func viewDidLoad() {
    super.viewDidLoad()
    self.configure()             // Static setup
    self.configureCollectionView()
    self.configureDataSource()
    self.configureBindings()     // ALWAYS LAST
}
```

---

## Dependencies (SPM)

Active: MustacheKit (Services/Combine/UIKit/Foundation — branch `4.0.0/SwiftUI`), Firebase (Analytics, Crashlytics), AppAuth (OAuth), Factory (DI)

---

## Agent Guides

Detailed instructions for specific tasks live in `.claude/agents/` (symlinked to `~/.claude/agents/`):

| Agent | File | Use when... |
|-------|------|-------------|
| **Jira** | [`.claude/agents/jira.md`](.claude/agents/jira.md) | Fetching tickets, extracting and validating acceptance criteria |
| **Figma** | [`.claude/agents/figma.md`](.claude/agents/figma.md) | Validating design against ACs, producing UI component breakdowns |
| **Architecture** | [`.claude/agents/architecture.md`](.claude/agents/architecture.md) | Making architectural decisions, understanding patterns, reviewing design |
| **New Feature** | [`.claude/agents/new-feature.md`](.claude/agents/new-feature.md) | Implementing a new module or feature from scratch |
| **Code Review** | [`.claude/agents/code-review.md`](.claude/agents/code-review.md) | Reviewing PRs, checking conventions, catching anti-patterns |
| **Networking** | [`.claude/agents/networking.md`](.claude/agents/networking.md) | Adding API endpoints, response models, network service methods |
| **UI Components** | [`.claude/agents/ui-components.md`](.claude/agents/ui-components.md) | Building views, cells, collection views, using the design system |
| **Bugfix** | [`.claude/agents/bugfix.md`](.claude/agents/bugfix.md) | Diagnosing issues, tracing data flow, fixing bugs |
| **Linting** | [`.claude/agents/linting.md`](.claude/agents/linting.md) | Code style, lint rules, formatting |
