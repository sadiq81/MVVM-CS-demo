import Vapor

struct OnboardingStateRequest: Content {
    
    var step: OnboardingState.Step
    var state: OnboardingState.State
    
    init(step: OnboardingState.Step, state: OnboardingState.State) {
        self.step = step
        self.state = state
    }
    
}

extension OnboardingStateRequest: Validatable {
    static func validations(_ validations: inout Validations) {
        validations.add("step", as: String.self, is: !.empty)
        validations.add("state", as: String.self, is: !.empty)
    }
}

extension OnboardingState {
    convenience init(from request: OnboardingStateRequest, userID: UUID) {
        self.init(userID: userID, step: request.step, state: request.state)
    }
}
