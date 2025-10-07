# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview
Vapor 4 authentication template showcasing user authentication, JWT tokens, email verification, password reset, queues, and repository pattern. Built with Swift 5.2+ and designed for deployment to Heroku.

## Architecture

### Repository Pattern
All database operations are abstracted through repository protocols defined in `Sources/App/Services/Repositories.swift`:
- Each entity has a corresponding repository protocol (e.g., `UserRepository`, `RefreshTokenRepository`)
- Database implementations follow the naming convention `Database*Repository`
- Repositories are registered in `configure.swift` via `app.repositories.use(.database)`
- Access repositories via request extensions: `req.users`, `req.refreshTokens`, etc.

### Controllers & Routes
Controllers use Vapor's `RouteCollection` pattern:
- All routes are prefixed with `/api` (see `routes.swift`)
- Controllers: `AuthenticationController`, `UserController`, `ProductController`, `DashboardController`, `OnboardingStateController`, `InstallationController`
- Authentication uses JWT access tokens (15 min) and refresh tokens (7 days)
- Protected routes use `UserAuthenticator()` middleware

### Database & Migrations
- Supports both PostgreSQL (production) and SQLite (development)
- DATABASE_URL triggers PostgreSQL with TLS
- Without DATABASE_URL, uses `db.sqlite` file
- Migrations defined in `Sources/App/Migrations/`
- Auto-migration runs in development environment (see `configure.swift:76`)

### Email System
- Email jobs queued via Redis using Vapor Queues
- Email templates in `Sources/App/Emails/`: `VerificationEmail`, `ResetPasswordEmail`
- Mailgun integration (currently commented out in `configure.swift`)
- Queue jobs defined in `Sources/App/Jobs/EmailJob.swift`

### Configuration
- `AppConfig` loads from environment variables: `SITE_FRONTEND_URL`, `SITE_API_URL`, `NO_REPLY_EMAIL`
- JWT signing uses JWKS file at path specified by `JWKS_KEYPAIR_FILE` (default: `keypair.jwks`)
- Token lifetimes in `Constants.swift`

## Development Commands

### Build & Run
```bash
swift build                           # Build project
swift run                            # Run server (development mode with auto-migration)
swift run Run serve --env production # Run in production mode
```

### Database
```bash
swift run Run migrate               # Run migrations manually
swift run Run migrate --revert      # Revert last migration
```

### Testing
```bash
swift test                          # Run test suite
```
Note: Test target currently commented out in `Package.swift`

### Queues
Queue worker starts automatically in development. For production:
```bash
swift run Run queues                # Start queue worker
```

### Heroku Deployment
Procfile command: `Run serve --env $ENVIRONMENT --hostname 0.0.0.0 --port $PORT`

## Environment Variables
Required for production:
- `DATABASE_URL` - PostgreSQL connection URL
- `SITE_FRONTEND_URL` - Frontend URL for reset password links
- `SITE_API_URL` - API URL for email verification links
- `NO_REPLY_EMAIL` - No-reply email address
- `JWKS_KEYPAIR_FILE` - Path to JWKS keypair file (default: `keypair.jwks`)
- `MAILGUN_API_KEY` - Mailgun API key
- `REDIS_URL` - Redis connection for queues (default: `redis://127.0.0.1:6379`)

Optional PostgreSQL (local development):
- `POSTGRES_HOSTNAME`, `POSTGRES_USERNAME`, `POSTGRES_PASSWORD`, `POSTGRES_DATABASE`

## Key Files
- `configure.swift` - Application configuration, middleware, services setup
- `routes.swift` - Route registration
- `migrations.swift` - Migration registration
- `queues.swift` - Queue job registration
- `services.swift` - Service dependency injection setup
- `AppConfig.swift` - Application configuration struct
- `Constants.swift` - Token lifetime constants
