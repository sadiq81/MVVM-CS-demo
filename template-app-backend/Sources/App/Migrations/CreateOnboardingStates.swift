@preconcurrency import Fluent

struct CreateOnboardingStates: Migration {
    
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        let onboardingStep = database.enum("onboarding_step")
            .case("location")
            .case("notification")
            .case("camera")
            .create()
        
        let onboardingState = database.enum("onboarding_state")
            .case("pending")
            .case("skipped")
            .case("completed")
            .create()
        
        return EventLoopFuture
            .whenAllSucceed([onboardingStep, onboardingState], on: database.eventLoop)
            .flatMap { enums in
                guard let onboardingStep = enums[safe: 0],
                      let onboardingState = enums[safe: 1]
                else { return database.eventLoop.makeFailedFuture(FluentError.relationNotLoaded(name: "onboardingStep, onboardingState")) }
                
                return database.schema("user_onboarding_states")
                    .id()
                    .field("user_id", .uuid, .required, .references("users", "id", onDelete: .cascade))
                    .field("step", onboardingStep, .required)
                    .field("state", onboardingState, .required)
                    .unique(on: "user_id", "step")
                    .create()
            }
    }
    
    func revert(on database: Database) -> EventLoopFuture<Void> {
        return database.schema("user_onboarding_states").delete()
            .flatMap { _ in
                database.enum("onboarding_step").delete()
            }
            .flatMap { _ in
                database.enum("onboarding_state").delete()
            }
    }
}
