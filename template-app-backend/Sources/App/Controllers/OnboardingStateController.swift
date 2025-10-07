import Vapor
import Fluent

struct OnboardingStateController: RouteCollection {

    func boot(routes: RoutesBuilder) throws {
        
        routes.group("onboarding") { onboarding in
            // Authentication required
            onboarding.group(UserAuthenticator()) { authenticated in
                
                authenticated.get("", use: self.list)
                authenticated.post("", use: self.post)
            }
        }
    }
    
    private func list(_ req: Request) async throws -> [OnboardingStateResponse] {
        let payload = try req.auth.require(Payload.self)
        
        let states = try await req.onboardingStates.find(for: payload.userID)
        let response = states.map { OnboardingStateResponse(from: $0) }
        return response
    }
    
    private func post(_ req: Request) async throws -> [OnboardingStateResponse] {
        let payload = try req.auth.require(Payload.self)
        
        try OnboardingStateRequest.validate(content: req)
        let onboardingRequest = try req.content.decode(OnboardingStateRequest.self)
        
        let states = try await req.onboardingStates.find(for: payload.userID)
        
        if let existing = states.first(where: { $0.step == onboardingRequest.step }) {
            existing.state = onboardingRequest.state
            try await req.onboardingStates.update(existing)
        } else {
            let onboarding = OnboardingState(from: onboardingRequest, userID: payload.userID)
            try await req.onboardingStates.create(onboarding)
        }
        
        let updatedStates = try await req.onboardingStates.find(for: payload.userID)
        let response = updatedStates.map { OnboardingStateResponse(from: $0) }
        return response
            
    }
    
}
