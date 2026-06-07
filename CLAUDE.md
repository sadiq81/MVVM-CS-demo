# Template App

Full-stack MVVM-CS architecture showcase: Vapor 4 backend + 3 iOS apps (UIKit, Mixed, SwiftUI).

---

## Project Essentials

- **Monorepo** with two sub-projects — each has its own `CLAUDE.md`:
  - [`template-app-backend/`](template-app-backend/CLAUDE.md) — Vapor 4 REST API
  - [`template-app-ios/`](template-app-ios/CLAUDE.md) — 3 iOS apps sharing one Xcode project
- **Medium article**: [MVVM-CS Architecture for iOS](https://medium.com/@nicktits/mvvm-cs-architecture-for-ios-a-complete-guide-from-uikit-to-swiftui-bb91c0c3cf2c)

---

## Repository Structure

```
template-app/
├── template-app-backend/         # Vapor 4 Swift backend
│   └── Sources/App/
└── template-app-ios/             # 3 iOS apps
    ├── Config/                   # Shared xcconfig base files
    ├── Resources/                # Shared assets (Images, Fonts, Localization, Video, Colors)
    ├── customerapp-Shared/       # Shared code (models, services, networking, SwiftUI views)
    ├── customerapp-UIKit/        # App 1: Pure UIKit
    ├── customerapp-Mixed/        # App 2: UIKit + SwiftUI (symlinks to SwiftUI views)
    ├── customerapp-SwiftUI/      # App 3: Pure SwiftUI
    └── customerapp.xcodeproj     # Xcode project (6 targets)
```

---

## Quick Start

```bash
# Backend
cd template-app-backend
swift build && swift run          # localhost:8080

# iOS (any of the 6 schemes)
cd template-app-ios
xcodebuild -project customerapp.xcodeproj -scheme UIKit-Development -destination 'generic/platform=iOS Simulator' build
```

Development schemes connect to `localhost:8080`. Start the backend first.

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
