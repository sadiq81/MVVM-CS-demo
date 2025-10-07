import Foundation
import MustacheFoundation
import MustacheServices

enum DashboardEndpoint {

    case dashbord

}

extension DashboardEndpoint: Endpoint {

    var baseURL: URL {
        switch self {
            default:
                return Environment.backendURL
        }
    }

    var method: RequestType {
        switch self {
            default:
                return .get
        }
    }

    var path: String {
        switch self {
            case .dashbord:
                return "/dashboard"
        }
    }

    var parameters: [String: String]? {
        switch self {
            default:
                return nil
        }
    }

    var headers: [String: String] {
        return Environment.baseHeaders
    }

    var body: Any? {
        switch self {
            default:
                return nil
        }
    }
    
//    var demoData: Decodable? {
//        switch self {
//            case .dashbord:
//                return DashboardResponse.mockData
//        }
//    }

    var authentication: Authentication {
        return .none
    }

}

extension AsyncNetworkServiceType {

    func dashboard() async throws -> DashboardResponse {
        let endpoint = DashboardEndpoint.dashbord
        return try await self.send(endpoint: endpoint)
    }

}
