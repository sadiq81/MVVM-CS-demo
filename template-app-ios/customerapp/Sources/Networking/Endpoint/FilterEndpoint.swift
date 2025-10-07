import Foundation
import MustacheFoundation
import MustacheServices

enum FilterEndpoint {

    case list

}

extension FilterEndpoint: Endpoint {

    var baseURL: URL {
        switch self {
            default: return Environment.backendURL
        }
    }

    var method: RequestType {
        switch self {
            default: return .get
        }
    }

    var path: String {
        switch self {
            case .list: return "/products/filters"
        }
    }

    var parameters: [String: String]? {
        switch self {
            default: return nil
        }
    }

    var headers: [String: String] { return Environment.baseHeaders }

    var body: Any? {
        switch self {
            default: return nil
        }
    }

    var authentication: Authentication { return .oauth }

}

extension AsyncNetworkServiceType {

    func getFilters() async throws  -> FilterReponse {
        let endpoint = FilterEndpoint.list
        return try await self.send(endpoint: endpoint)
    }

}
