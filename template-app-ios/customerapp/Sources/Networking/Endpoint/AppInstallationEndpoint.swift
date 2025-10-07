import Foundation
import MustacheFoundation
import MustacheServices

enum AppInstallationEndpoint {

    case installation(InstallationRequest)
    case updateFCMToken(FCMTokenRequest)

}

extension AppInstallationEndpoint: Endpoint {

    var baseURL: URL {
        return Environment.backendURL
    }

    var method: RequestType {
        switch self {
            case .installation:
                return .post
            case .updateFCMToken:
                return .put
        }
    }

    var path: String {
        switch self {
            case .installation:
                return "/installation"
            case .updateFCMToken(let request):
                return "/installation/\(request.installationId)/device-token"
        }
    }

    var headers: [String: String] {
        return Environment.baseHeaders
    }

    var body: Any? {
        switch self {
            case .installation(let request):
                return request
            case .updateFCMToken(let request):
                return request
        }
    }
    
//    var demoData: Decodable? {
//        switch self {
//            case .installation:
//                return InstallationResponse.mockData
//            case .updateFCMToken:
//                return EmptyReply()
//        }
//    }

    var authentication: Authentication {
        switch self {
            case .installation:
                return .none
            case .updateFCMToken:
                return .oauth
        }
    }

    var encoding: EncodingType {
        switch self {
            case .installation:
                return .json()
            case .updateFCMToken:
                return .json()
        }
    }

}

extension AsyncNetworkServiceType {

    func installation(request: InstallationRequest) async throws -> InstallationResponse {
        let endpoint = AppInstallationEndpoint.installation(request)
        return try await self.send(endpoint: endpoint)
    }

    @discardableResult
    func update(request: FCMTokenRequest) async throws -> EmptyReply {
        let endpoint = AppInstallationEndpoint.updateFCMToken(request)
        return try await self.send(endpoint: endpoint)
    }

}
