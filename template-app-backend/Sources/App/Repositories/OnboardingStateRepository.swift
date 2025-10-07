import Vapor
import Fluent

protocol OnboardingStateRepository: Repository {
    
    func create(_ state: OnboardingState) async throws
    
    func create(_ states: [OnboardingState]) async throws
    
    func update(_ state: OnboardingState) async throws
    
    func find(for userID: UUID) async throws -> [OnboardingState]
}

struct DatabaseOnboardingStateRepository: OnboardingStateRepository, DatabaseRepository {
    
    let database: Database
    
    func create(_ state: OnboardingState) async throws {
        try await state.create(on: self.database)
    }
    
    func create(_ states: [OnboardingState]) async throws {
        try await states.create(on: self.database)
    }
    
    func update(_ state: OnboardingState) async throws {
        try await state.update(on: self.database)
    }
    
    func find(for userID: UUID) async throws -> [OnboardingState] {
        return try await OnboardingState.query(on: self.database)
            .filter(\.$user.$id == userID)
            .all()
    }
}

extension Application.Repositories {
    
    var onboardingStates: OnboardingStateRepository {
        guard let factory = storage.makeOnboardingStatesRepository else {
            fatalError("OnboardingState repository not configured, use: app.repositories.use")
        }
        return factory(app)
    }
    
    func use(_ make: @escaping (Application) -> (OnboardingStateRepository)) {
        storage.makeOnboardingStatesRepository = make
    }
}
