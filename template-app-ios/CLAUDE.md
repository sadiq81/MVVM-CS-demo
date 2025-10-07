# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Build and Development Commands

### Building the Project
```bash
# Open project in Xcode
open customerapp.xcodeproj

# Build for Development scheme (connects to localhost:8080)
xcodebuild -project customerapp.xcodeproj -scheme Development -configuration Debug build

# Build for Production scheme
xcodebuild -project customerapp.xcodeproj -scheme Production -configuration Release build
```

### Targets and Schemes
- **Schemes:** Development, Production
- **Targets:** Production, Development
- **Build Configurations:** Debug, Release

### Environment Configuration
Configuration files are located in `customerapp/Resources/Config/`:
- `Development.xcconfig` - Dev environment (backend: localhost:8080 or configurable)
- `Production.xcconfig` - Production environment
- Secrets are stored in `customerapp/Resources/Config/Secrets/` and are gitignored

### Resource Generation
SwiftGen is used for type-safe resources (configured in `swiftgen.yml`):
```bash
# Generate resource files (Images, Strings, Fonts, Colors)
swiftgen
```

Generated files:
- Images: `customerapp/Resources/Images/Images.swift`
- Strings: `customerapp/Resources/Localization/Strings.swift`
- Fonts: `customerapp/Resources/Fonts/Fonts.swift`
- Colors: `customerapp/Sources/DesignSystem/Base/Color/Colors.swift`

## Architecture Overview

### Coordinator Pattern
The app uses the **Coordinator pattern** for navigation and flow control:

- **AppCoordinator** (`customerapp/Sources/Modules/001_Application/Routing/AppCoordinatorType.swift`)
  - Root coordinator managing app lifecycle
  - Handles transitions between major flows: Splash → Login → Onboarding → TabBar
  - Manages child coordinators using weak references in `NSHashTable`
  - Transitions defined in `AppTransition` enum: `.splashCompleted`, `.login`, `.loginCompleted`, `.onboarding`, `.onboardingCompleted`

- **Module Coordinators** (e.g., `LoginCoordinator`, `MoreCoordinator`, `TabBarCoordinator`)
  - Each module has its own coordinator inheriting from `CoordinatorType` (from MustacheKit)
  - Coordinators own navigation controllers and manage view controller presentations
  - Module-specific transitions defined in module-specific enums (e.g., `MoreTransition`, `LoginTransition`)
  - Parent-child relationships: coordinators have weak `parent` references and can pass transitions up the chain

**Key Coordinator Methods:**
- `start()` - Initialize and present first view controller
- `stop()` - Cleanup (optional)
- `transition(to: Transition)` - Handle navigation transitions
- `route(to: Route)` - Handle deep linking/routing

### Module Structure
Modules are numbered and organized in `customerapp/Sources/Modules/`:
- `001_Application` - App delegate, coordinator, appearance
- `002_TabBarController` - Main tab bar
- `003_Common` - Shared components
- `010_Splash` - Splash screen
- `020_Login` - Login flow
- `030_Onboarding` - Onboarding flow
- `040_Dashboard` - Dashboard
- `04_Profile` - User profile
- `050_Search` - Search functionality
- `060_Feature1` - Feature placeholder
- `070_Products` - Product catalog
- `080_More` - More/Settings tab
- `090_Pin` - PIN authentication

Each module typically contains:
- `ViewController/` - View controllers with associated .swift and .storyboard files
- `ViewModel/` - View model protocols and implementations (e.g., `*ViewModelType.swift`)
- `Routing/` - Coordinator for the module
- `Cell/` - Custom table/collection view cells (with .xib files)

### MVVM + Coordinator Architecture
- **View Controllers**: Handle UI, bound to ViewModels
- **ViewModels**: Business logic, data transformation, Combine publishers
  - Named with `*ViewModelType` protocol pattern
  - Registered in Resolver as `.shared` scope
  - Use `@Injected` for service dependencies
  - Expose data via Combine `AnyPublisher` properties
- **Services**: Data layer, API calls, persistence
- **Coordinators**: Navigation and flow control

### Dependency Injection
Uses **Resolver** (from MustacheKit) for DI:
- Registration in `customerapp/Sources/Extensions/Resolver/Resolver+ResolverRegistering.swift`
- Property wrappers:
  - `@Injected` - Immediate injection
  - `@LazyInjected` - Lazy injection (resolved on first access)
- Scopes:
  - `.application` - Single instance for app lifetime
  - `.shared` - Shared instance
  - `.unique` - New instance each time (default)

**Key Registered Services:**
- Network: `AsyncCredentialsServiceType`, `AsyncTokenServiceType`, `AsyncNetworkServiceType`
- Business: `LoginServiceType`, `UserServiceType`, `DashboardServiceType`, `ProductServiceType`
- Storage: `SecureStorageServiceType`, `InstallationServiceType`
- ViewModels: All registered with `.shared` scope

### Networking Layer
Located in `customerapp/Sources/Networking/`:
- `Endpoint/` - API endpoint definitions (e.g., `UserEndPoint`, `AuthenticationEndpoint`)
- `Request/` - Request models
- `Response/` - Response models
- Services use `AsyncNetworkServiceType` from MustacheKit
- OAuth token refresh handled by `AsyncTokenServiceType`
- Credentials stored via `AsyncCredentialsServiceType`

### Design System
Two approaches available in `customerapp/Sources/DesignSystem/`:

**Method 1 - Extensions** (`Method 1 Extensions/`):
- Extensions on UIKit components (e.g., `UIButton+Style.swift`)
- Apply styles via extension methods

**Method 2 - Subclassing** (`Method 2 Subclass/`):
- Custom styled components (e.g., `StyledButton`, `StyledLabel`, `StyledTextField`)
- Inherit and configure

**Base Design System** (`Base/`):
- `Colors.swift` - Generated from Colors.xcassets via SwiftGen
- `Appearance.swift` - Global appearance configuration
- `UIButton.Style` enum - Button style definitions (primary, secondary, tertiary, link)
- `UIFont+SwizzlePreferredFont.swift` - Dynamic type support

### Storyboards and XIBs
- Main storyboards: `customerapp/Resources/Interfaces/Storyboards/`
- Module-specific storyboards: Inside each module's `ViewController/` folder
- XIBs: Used for custom cells in `Cell/` folders
- View controllers instantiated via `AppStoryboard.viewController(class:)` helper

### Extensions
Organized by framework in `customerapp/Sources/Extensions/`:
- `UIKit/` - UIKit extensions (view controllers, controls, views)
- `Foundation/` - Foundation extensions
- `Combine/` - Combine utilities
- `Concurrency/` - Swift Concurrency helpers
- `Async/` - Async utilities
- `AppAuth/` - AppAuth extensions
- `Resolver/` - Resolver configuration

## Key Dependencies (SPM)
- **MustacheKit** - Core framework providing networking, services, UI utilities
  - `MustacheFoundation`, `MustacheServices`, `MustacheUIKit`, `MustacheCombine`
- **Firebase** - Analytics, Crashlytics (configured in AppDelegate)
- **AppAuth** - OAuth/OpenID authentication
- **Kingfisher** - Image loading/caching
- **RxSwift** - Reactive programming
- **Lottie** - Animations

## CI/CD (Xcode Cloud)
CI scripts in `ci_scripts/`:
- `ci_post_clone.sh` - Creates secrets files from Xcode Cloud environment variables
- `ci_post_xcodebuild.sh` - Uploads dSYMs, creates release notes, tags builds

## Common Development Patterns

### Adding a New Feature Module
1. Create numbered folder in `customerapp/Sources/Modules/`
2. Create subdirectories: `ViewController/`, `ViewModel/`, `Routing/`, `Cell/` (if needed)
3. Implement ViewModel protocol and concrete class
4. Register ViewModel in `Resolver+ResolverRegistering.swift`
5. Create Coordinator inheriting from `CoordinatorType`
6. Define transitions enum conforming to `Transition`
7. Implement view controller with coordinator reference
8. Wire up navigation from parent coordinator

### Adding a New Service
1. Create protocol `*ServiceType` in `customerapp/Sources/Services/`
2. Implement concrete class
3. Register in `Resolver+ResolverRegistering.swift` with appropriate scope
4. Inject via `@Injected` or `@LazyInjected` where needed

### Adding a New Endpoint
1. Define endpoint in `customerapp/Sources/Networking/Endpoint/`
2. Create request model in `customerapp/Sources/Networking/Request/`
3. Create response model in `customerapp/Sources/Networking/Response/`
4. Extend `AsyncNetworkServiceType` with method (or use generic request method)

### Coordinator Navigation Flow
- Use `transition(to:)` for same-level or child transitions
- Use `parent?.transition(to:)` to pass transitions up the hierarchy
- Store child coordinators in parent's `children` weak hash table
- Call `parent?.stop(with: self)` when flow completes (e.g., login completed)

### Using ViewModels
- ViewModels expose `AnyPublisher` properties for reactive UI updates
- Subscribe to publishers in view controller's `viewDidLoad` or `configure()`
- Store subscriptions in `cancellables` set
- Call ViewModel methods (e.g., `refresh()`) for actions
- ViewModels use `@Injected` services for data operations

## Important Notes
- Authentication uses OAuth flow via `LoginService` and `AsyncCredentialsService`
- Secure data stored via `SecureStorageServiceType` (uses Keychain on device, simulator uses UserDefaults)
- Onboarding state tracked via `OnboardingServiceType`
- Deep linking handled through `route(to:)` coordinator method
- Dynamic Type supported via font swizzling in `UIFont+SwizzlePreferredFont.swift`
