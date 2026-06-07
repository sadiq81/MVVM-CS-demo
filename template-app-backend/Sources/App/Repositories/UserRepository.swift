import Vapor
import Fluent

protocol UserRepository: Repository {
    
    func create(_ user: User) async throws
    
    func update(_ user: User) async throws
    
    func delete(id: UUID) async throws -> Void
    
    func all() async throws  -> [User]
    
    func find(id: UUID?) async throws -> User?
    
    func find(email: String) async throws -> User?
    
    func set<Field>(_ field: KeyPath<User, Field>, to value: Field.Value, for userID: UUID) async throws where Field: QueryableProperty, Field.Model == User
   
    func count() async throws -> Int
    
    func flags(for userID: UUID) async throws -> [FeatureFlag]
    
    func create(flag: FeatureFlag) async throws
    
    func delete(flag: FeatureFlag) async throws
}

struct DatabaseUserRepository: UserRepository, DatabaseRepository {
    
    let database: Database
    
    func create(_ user: User) async throws {
        return try await user.create(on: self.database)
    }
    
    func update(_ user: User) async throws {
        return try await user.update(on: self.database)
    }
    
    func delete(id: UUID) async throws -> Void {
        return try await User.query(on: self.database)
            .filter(\.$id == id)
            .delete()
    }
    
    func all() async throws -> [User] {
        return try await User.query(on: self.database).all()
    }
    
    func find(id: UUID?) async throws -> User? {
        return try await User.find(id, on: self.database)
    }
    
    func find(email: String) async throws -> User? {
        return try await User.query(on: self.database)
            .filter(\.$email == email)
            .first()
    }
    
    func set<Field>(_ field: KeyPath<User, Field>, to value: Field.Value, for userID: UUID) async throws where Field: QueryableProperty, Field.Model == User {
        return try await User.query(on: self.database)
            .filter(\.$id == userID)
            .set(field, to: value)
            .update()
    }
    
    func count() async throws -> Int {
        return try await User.query(on: self.database).count()
    }
    
    func flags(for userID: UUID) async throws -> [FeatureFlag] {
        return try await FeatureFlag.query(on: self.database)
            .filter(\.$user.$id == userID)
            .all()
    }
    
    func create(flag: FeatureFlag) async throws {
        return try await flag.create(on: self.database)
    }
    
    func delete(flag: FeatureFlag) async throws {
        return try await flag.delete(on: self.database)
    }
}

extension Application.Repositories {
    var users: UserRepository {
        guard let storage = storage.makeUserRepository else {
            fatalError("UserRepository not configured, use: app.userRepository.use()")
        }
        
        return storage(app)
    }
    
    func use(_ make: @escaping (Application) -> (UserRepository)) {
        storage.makeUserRepository = make
    }
}



