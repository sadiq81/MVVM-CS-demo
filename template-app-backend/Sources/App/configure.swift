import Fluent
import FluentPostgresDriver
import FluentSQLiteDriver
import Vapor
import JWT
import Mailgun
import QueuesRedisDriver

public func configure(_ app: Application) throws {
    // MARK: JWT
    if app.environment != .testing {
        let jwksFilePath = app.directory.workingDirectory + (Environment.get("JWKS_KEYPAIR_FILE") ?? "keypair.jwks")
         guard
             let jwks = FileManager.default.contents(atPath: jwksFilePath),
             let jwksString = String(data: jwks, encoding: .utf8)
             else {
                 fatalError("Failed to load JWKS Keypair file at: \(jwksFilePath)")
         }
         try app.jwt.signers.use(jwksJSON: jwksString)
    }
    
    // MARK: Database
    // Configure PostgreSQL database
    if let databaseURL = Environment.get("DATABASE_URL") {
        
        // https://docs.vapor.codes/deploy/heroku/#configure-the-database
        var tlsConfig: TLSConfiguration = .makeClientConfiguration()
        tlsConfig.certificateVerification = .none
        let nioSSLContext = try NIOSSLContext(configuration: tlsConfig)
        
        var postgresConfig = try SQLPostgresConfiguration(url: databaseURL)
        postgresConfig.coreConfiguration.tls = .require(nioSSLContext)
        
        app.databases.use(.postgres(configuration: postgresConfig), as: .psql)

    } else {
        
        app.databases.use(DatabaseConfigurationFactory.sqlite(.file("db.sqlite")), as: .sqlite)
        
//        app.databases.use(
//            .postgres(
//                hostname: Environment.get("POSTGRES_HOSTNAME") ?? "localhost",
//                username: Environment.get("POSTGRES_USERNAME") ?? "vapor",
//                password: Environment.get("POSTGRES_PASSWORD") ?? "password",
//                database: Environment.get("POSTGRES_DATABASE") ?? "vapor"
//            ), as: .psql)
    }
    
        
    // MARK: Middleware
    app.middleware = .init()
    app.middleware.use(ErrorMiddleware.custom(environment: app.environment))
    
    // MARK: Model Middleware
    
    // MARK: Mailgun
//    app.mailgun.configuration = .environment
//    app.mailgun.defaultDomain = .sandbox
    
    // MARK: App Config
    app.config = .environment
    
    // MARK: Routes
    try routes(app)
    
    // MARK: Migrations
    try migrations(app)
    
    // MARK: Queues
    try queues(app)
    
    // MARK: Services
    try services(app)
        
    if app.environment == .development {
        try app.autoMigrate().wait()
//        try app.queues.startInProcessJobs()
    }
}
