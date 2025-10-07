import Foundation
import MustacheFoundation
import MustacheServices

enum ProductEndpoint {

    case list(search: String?, brands: String? = nil, categories: String? = nil, limit: Int?, skip: Int?)

}

extension ProductEndpoint: Endpoint {

    var baseURL: URL {
        return Environment.backendURL
    }

    var method: RequestType {
        switch self {
            case .list: return .get
        }
    }

    var parameters: [String: String]? {
        switch self {
            case .list(let search, let brands, let categories, let limit, let skip):
                var parameters: [String: String] = [:]
                if let search, !search.isEmpty {
                    parameters["search"] = search
                }
                if let brands {
                    parameters["brands"] = brands
                }
                if let categories {
                    parameters["categories"] = categories
                }
                if let limit, let skip {
                    parameters["limit"] = "\(limit)"
                    parameters["skip"] = "\(skip)"
                }
                return parameters
        }
    }

    var path: String {
        switch self {
            case .list:
                return "/products"
        }
    }

    var headers: [String: String] {
        return Environment.baseHeaders
    }

    var body: Any? {
        return nil
    }

    var encoding: EncodingType {
        return .none
    }

    var authentication: Authentication {
        return .oauth
    }

    var cachePolicy: URLRequest.CachePolicy {
        return .reloadIgnoringLocalAndRemoteCacheData
    }

}

extension AsyncNetworkServiceType {

    func products(search: String? = nil,
                  brands: String?,
                  categories: String?,
                  limit: Int = 20,
                  skip: Int = 0) async throws -> ProductPaginatedResponse {

        let endpoint = ProductEndpoint.list(search: search,
                                            brands: brands,
                                            categories: categories,
                                            limit: limit,
                                            skip: skip)

        return try await self.send(endpoint: endpoint)
    }

}
