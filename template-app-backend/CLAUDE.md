# Template App Backend

Vapor 4 authentication template with JWT tokens, email verification, password reset, queues, and repository pattern.

---

## Project Essentials

- **Build**: `swift build`
- **Run**: `swift run` (localhost:8080, auto-migration in development)
- **Test**: `swift test`

---

## Project Structure

```
Sources/App/
  Controllers/              # Route handlers (RouteCollection)
    AuthenticationController
    UserController
    ProductController
    DashboardController
    OnboardingStateController
    InstallationController
  Migrations/               # Fluent migrations
  Models/                   # Fluent models
  Services/
    Repositories.swift      # Repository protocols (UserRepository, RefreshTokenRepository, etc.)
  Jobs/
    EmailJob.swift           # Queue-based email dispatch
  Emails/                   # Email templates (VerificationEmail, ResetPasswordEmail)
  configure.swift            # App configuration, middleware, services
  routes.swift               # Route registration (all prefixed /api)
  migrations.swift           # Migration registration
  queues.swift               # Queue job registration
  services.swift             # Service DI setup
```

---

## Architecture Quick Reference

```
Controller  →  handles HTTP request, calls Repository
Repository  →  protocol + Database*Repository implementation
Model       →  Fluent model (database entity)
```

- **Repository pattern**: All DB operations abstracted through protocols in `Repositories.swift`
- **Registration**: `app.repositories.use(.database)` in `configure.swift`
- **Access**: Via request extensions — `req.users`, `req.refreshTokens`, etc.

---

## Key Patterns

| Pattern | Convention |
|---------|-----------|
| Routes | All prefixed with `/api` |
| Auth | JWT access tokens (15 min) + refresh tokens (7 days) |
| Protected routes | Use `UserAuthenticator()` middleware |
| Database | PostgreSQL (prod, via `DATABASE_URL`) or SQLite (dev, `db.sqlite`) |
| Email | Queued via Redis (Vapor Queues) + Mailgun |
| Config | `AppConfig` loads from environment variables |
| JWT signing | JWKS file at `JWKS_KEYPAIR_FILE` (default: `keypair.jwks`) |

---

## Database

```bash
swift run Run migrate               # Apply migrations
swift run Run migrate --revert      # Rollback last migration
```

- `DATABASE_URL` present → PostgreSQL with TLS
- No `DATABASE_URL` → SQLite (`db.sqlite`)
- Auto-migration in development environment

---

## Environment Variables

**Required (production):**
- `DATABASE_URL` — PostgreSQL connection
- `SITE_FRONTEND_URL` — Frontend URL for reset password links
- `SITE_API_URL` — API URL for email verification links
- `NO_REPLY_EMAIL` — No-reply email address
- `JWKS_KEYPAIR_FILE` — JWKS keypair path (default: `keypair.jwks`)
- `MAILGUN_API_KEY` — Mailgun API key
- `REDIS_URL` — Redis for queues (default: `redis://127.0.0.1:6379`)

**Optional (local PostgreSQL):**
- `POSTGRES_HOSTNAME`, `POSTGRES_USERNAME`, `POSTGRES_PASSWORD`, `POSTGRES_DATABASE`

---

## Deployment

Heroku via Procfile: `Run serve --env $ENVIRONMENT --hostname 0.0.0.0 --port $PORT`

Queue worker (production): `swift run Run queues`
