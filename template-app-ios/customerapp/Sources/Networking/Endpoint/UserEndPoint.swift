import Foundation
import MustacheFoundation
import MustacheServices

enum UserEndPoint {

    case get
    case getFeatureFlags
    case setFeatureFlag(request: FeatureFlagRequest)
    case put(request: UserPutRequest)
    case verify(request: VerifyAgeRequest)

}

extension UserEndPoint: Endpoint {

    var baseURL: URL {
        return Environment.backendURL
    }

    var method: RequestType {
        switch self {
            case .get: return .get
            case .getFeatureFlags: return .get
            case .setFeatureFlag: return .post
            case .put: return .put
            case .verify: return .post
        }
    }

    var parameters: [String: String]? {
        switch self {
            default: return nil
        }
    }

    var path: String {
        switch self {
            case .get: return "/user"
            case .getFeatureFlags, .setFeatureFlag: return "/user/feature-flags"
            case .put: return "/user"
            case .verify: return "/user/verify"
        }
    }

    var authentication: Authentication {
        switch self {
            default:
                return .oauth
        }
    }

    var headers: [String: String] {
        return Environment.baseHeaders
    }

    var body: Any? {
        switch self {
            case .put(let request):
                return request
            case .setFeatureFlag(let request):
                return request
            case .verify(let request):
                return request
            default:
                return nil
        }
    }
    
//    var demoData: Decodable? {
//        switch self {
//            case .get:
//                return UserResponse.mockData
//            case .getFeatureFlags:
//                return FeatureFlagResponse.mockData
//            case .setFeatureFlag:
//                return FeatureFlagResponse.mockData
//            case .put:
//                return UserResponse.mockData
//            case .verify:
//                return EmptyReply()
//            
//        }
//    }

    var encoding: EncodingType {
        switch self {
            case .put: return .json()
            case .setFeatureFlag: return .json()
            case .verify: return .json()
            default: return .none
        }
    }
}

extension AsyncNetworkServiceType {

    func getUser() async throws -> UserResponse {
        return try await self.send(endpoint: UserEndPoint.get)
    }

    func getFeatureFlags() async throws -> [FeatureFlagResponse] {
        return try await self.send(endpoint: UserEndPoint.getFeatureFlags)
    }
    
    func setFeatureFlag(request: FeatureFlagRequest) async throws -> [FeatureFlagResponse] {
        return try await self.send(endpoint: UserEndPoint.setFeatureFlag(request: request))
    }

    func put(request: UserPutRequest) async throws -> UserResponse {
        return try await self.send(endpoint: UserEndPoint.put(request: request))
    }
    
    @discardableResult
    func verifyAge(request: VerifyAgeRequest) async throws -> EmptyReply {
        return try await self.send(endpoint: UserEndPoint.verify(request: request))
    }

}
