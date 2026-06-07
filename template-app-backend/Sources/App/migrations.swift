import Vapor

func migrations(_ app: Application) throws {
    // Initial Migrations
    app.migrations.add(CreateUser())
    app.migrations.add(CreateOnboardingStates())
    app.migrations.add(CreateInstallation())
    app.migrations.add(CreateFeatureFlag())
    app.migrations.add(CreateRefreshToken())
    app.migrations.add(CreateEmailToken())
    app.migrations.add(CreatePasswordToken())
}
