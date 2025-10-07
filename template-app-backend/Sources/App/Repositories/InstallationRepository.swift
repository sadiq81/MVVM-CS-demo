import Vapor
import Fluent

protocol InstallationRepository: Repository {
    
    func create(_ installation: Installation) async throws
    
    func update(_ installation: Installation) async throws
    
    func find(id: UUID?) async throws -> Installation?
    
    func find(for userID: UUID) async throws -> [Installation]
}

struct DatabaseInstallationRepository: InstallationRepository, DatabaseRepository {
    
    let database: Database
    
   func create(_ installation: Installation) async throws {
        return try await installation.create(on: self.database)
    }
    
    func update(_ installation: Installation) async throws {
        return try await installation.update(on: self.database)
    }
    
    func find(id: UUID?) async throws -> Installation? {
        return try await Installation.find(id, on: self.database)
    }
    
    func find(for userID: UUID) async throws -> [Installation] {
        return try await Installation.query(on: self.database)
            .filter(\.$user.$id == userID)
            .all()
    }
}

extension Application.Repositories {
    
    var installations: InstallationRepository {
        guard let factory = storage.makeInstallationRepository else {
            fatalError("Installation repository not configured, use: app.repositories.use")
        }
        return factory(app)
    }
    
    func use(_ make: @escaping (Application) -> (InstallationRepository)) {
        storage.makeInstallationRepository = make
    }
}
