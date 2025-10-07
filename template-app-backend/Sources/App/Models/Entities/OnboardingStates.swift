
import Vapor
import Fluent

final class OnboardingState: Model {
    
    static let schema = "user_onboarding_states"
    
    @ID(key: .id)
    var id: UUID?
    
    @Parent(key: "user_id")
    var user: User
    
    @Enum(key: "step")
    var step: Step
    
    @Enum(key: "state")
    var state: State
    
    init() {}
    
    init(id: UUID? = nil, userID: UUID, step: Step, state: State) {
        self.id = id
        self.$user.id = userID
        self.step = step
        self.state = state
    }
}
extension OnboardingState {

    // Remember to add changes to CreateOnboardingStates
    enum Step: String, Codable, CaseIterable {
        case location, notification, camera
    }
    
    // Remember to add changes to CreateOnboardingStates
    enum State: String, Codable {
        case pending, completed, skipped
    }
    
}
