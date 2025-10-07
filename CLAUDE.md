# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a full-stack template application consisting of:
- **Backend**: Vapor 4 (Swift) REST API with JWT authentication (`template-app-backend/`)
- **iOS App**: Native iOS app using MVVM + Coordinator pattern (`template-app-ios/`)

Both projects are designed to work together, with the iOS app consuming the backend API.

## Repository Structure

```
template-app/
├── template-app-backend/    # Vapor 4 Swift backend
└── template-app-ios/         # iOS app (SwiftUI/UIKit)
```

Each subdirectory has its own CLAUDE.md with detailed information:
- See `template-app-backend/CLAUDE.md` for backend development
- See `template-app-ios/CLAUDE.md` for iOS development

## Quick Start

### Backend Development
```bash
cd template-app-backend
swift build                  # Build
swift run                    # Run server (localhost:8080)
swift test                   # Run tests
```

### iOS Development
```bash
cd template-app-ios
open customerapp.xcodeproj   # Open in Xcode
swiftgen                     # Generate resources (if needed)
# Build using Xcode or xcodebuild
```

## Development Workflow

### Running Both Projects Together
1. Start the backend server:
   ```bash
   cd template-app-backend
   swift run
   ```
2. Configure iOS app to use Development scheme (connects to localhost:8080)
3. Build and run iOS app in Xcode

### Environment Configuration
- **Backend**: Uses `.env.development` file and environment variables
- **iOS**: Uses `.xcconfig` files in `customerapp/Resources/Config/`
  - Development.xcconfig points to localhost:8080
  - Production.xcconfig points to production backend

## Architecture Overview

### Backend (Vapor 4)
- **Pattern**: Repository pattern for database access
- **Auth**: JWT access tokens (15 min) + refresh tokens (7 days)
- **Database**: PostgreSQL (production) or SQLite (development)
- **Email**: Queue-based email system with Mailgun
- **Key Features**: User auth, password reset, email verification, feature flags, onboarding states

### iOS App
- **Pattern**: MVVM + Coordinator for navigation
- **DI**: Resolver framework for dependency injection
- **Networking**: OAuth + JWT token management
- **Architecture**: Modular structure with numbered modules (001_Application, 020_Login, etc.)
- **Design System**: Type-safe resources via SwiftGen

## Common Development Tasks

### Adding New Backend Endpoint
1. Define route in appropriate controller (`template-app-backend/Sources/App/Controllers/`)
2. Add repository method if database access needed
3. Update migrations if schema changes required
4. Register route in `routes.swift`

### Adding New iOS Feature
1. Create numbered module folder in `customerapp/Sources/Modules/`
2. Implement ViewModel protocol and concrete class
3. Register ViewModel in `Resolver+ResolverRegistering.swift`
4. Create Coordinator for navigation
5. Wire up from parent coordinator

### Database Migrations
```bash
# Backend
cd template-app-backend
swift run Run migrate        # Apply migrations
swift run Run migrate --revert  # Rollback
```

### Running Tests
```bash
# Backend
cd template-app-backend
swift test

# iOS (use Xcode Test navigator or):
cd template-app-ios
xcodebuild test -project customerapp.xcodeproj -scheme Development
```

## Key Technologies

### Backend Stack
- Vapor 4 (Swift web framework)
- Fluent ORM (PostgreSQL/SQLite)
- JWT authentication
- Vapor Queues (Redis)
- Mailgun (email delivery)

### iOS Stack
- UIKit + Combine
- MustacheKit (networking, services)
- Firebase (Analytics, Crashlytics)
- AppAuth (OAuth)
- Kingfisher (image loading)
- SwiftGen (resource generation)

## Important Notes

- Both projects are Swift-based and share similar patterns
- Backend API runs on port 8080 by default
- iOS Development scheme expects backend at localhost:8080
- Authentication flow: iOS uses OAuth → Backend issues JWT tokens
- Secrets are gitignored (`.env.development`, `customerapp/Resources/Config/Secrets/`)
