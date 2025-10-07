import Foundation
import MustacheFoundation
import MustacheServices

enum OnboardingStatesEndpoint {
    case getOnboardingStates
    case updateOnboardingStates(String, String)
}

extension OnboardingStatesEndpoint: Endpoint {

    var baseURL: URL {
        return Environment.backendURL
    }

    var method: RequestType {
        switch self {
            case .getOnboardingStates: return .get
            case .updateOnboardingStates: return .post
        }
    }

    var path: String {
        switch self {
            case .getOnboardingStates, .updateOnboardingStates: return "/onboarding"
        }
    }

    var parameters: [String: String]? {
        switch self {
            default: return nil
        }
    }

    var headers: [String: String] {
        return Environment.baseHeaders
    }

    var body: Any? {
        switch self {
            case .updateOnboardingStates(let key, let value):
                return ["step": key, "state": value]
            default: return nil
        }
    }
    
//    var demoData: (any Decodable)? {
//        switch self {
//            case .getOnboardingStates:
//                return OnboardingStateResponse.mockData
//            case .updateOnboardingStates:
//                return OnboardingStateResponse.mockData
//        }
//    }

    var authentication: Authentication {
        return .oauth
    }

    var encoding: EncodingType {
        switch self {
            case .updateOnboardingStates: return .json()
            default: return .none
        }
    }

}

extension AsyncNetworkServiceType {

    func getOnboardingStates() async throws -> OnboardingStateResponseList {
        return try await self.send(endpoint: OnboardingStatesEndpoint.getOnboardingStates)
    }

    func updateOnboardingStates(step: OnboardingStep, state: OnboardingState) async throws  -> OnboardingStateResponseList {
        let endpoint = OnboardingStatesEndpoint.updateOnboardingStates(step.rawValue, state.rawValue)
        return try await self.send(endpoint: endpoint)
    }

}
