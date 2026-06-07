import Vapor

struct OnboardingStateResponse: Content {
    
    var step: OnboardingState.Step
    var state: OnboardingState.State
    
    init(step: OnboardingState.Step, state: OnboardingState.State) {
        self.step = step
        self.state = state
    }
    
    init(from onboardingState: OnboardingState) {
        self.init(step: onboardingState.step, state: onboardingState.state)
    }
}
