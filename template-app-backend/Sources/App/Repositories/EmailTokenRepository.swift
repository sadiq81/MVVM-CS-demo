import Vapor
import Fluent

protocol EmailTokenRepository: Repository {
    
    func find(token: String) async throws -> EmailToken?
    
    func create(_ emailToken: EmailToken) async throws
    
    func delete(_ emailToken: EmailToken) async throws
    
    func find(userID: UUID) async throws -> EmailToken?
}

struct DatabaseEmailTokenRepository: EmailTokenRepository, DatabaseRepository {
    
    let database: Database
    
    func find(token: String) async throws -> EmailToken? {
        return try await EmailToken.query(on: self.database)
            .filter(\.$token == token)
            .first()
    }
   
    func create(_ emailToken: EmailToken) async throws {
        return try await emailToken.create(on: self.database)
    }
    
    func delete(_ emailToken: EmailToken) async throws {
        return try await emailToken.delete(on: self.database)
    }
    
    func find(userID: UUID) async throws -> EmailToken? {
        return try await EmailToken.query(on: self.database)
            .filter(\.$user.$id == userID)
            .first()
    }
}

extension Application.Repositories {
    var emailTokens: EmailTokenRepository {
        guard let factory = storage.makeEmailTokenRepository else {
            fatalError("EmailToken repository not configured, use: app.repositories.use")
        }
        return factory(app)
    }
    
    func use(_ make: @escaping (Application) -> (EmailTokenRepository)) {
        storage.makeEmailTokenRepository = make
    }
}
