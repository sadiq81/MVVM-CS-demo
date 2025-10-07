import Foundation
import MustacheFoundation
import MustacheServices

enum AddressEndpoint {

    case autocomplete(query: String)

}

extension AddressEndpoint: Endpoint {

    var baseURL: URL {
        return URL(string: "https://api.dataforsyningen.dk")!
    }

    var method: RequestType {
        switch self {
            case .autocomplete:
                return .get
        }
    }

    var path: String {
        switch self {
            case .autocomplete:
                return "/autocomplete"
        }
    }
    
    var parameters: [String: String]? {
        switch self {
            case .autocomplete(let query):
                return ["q": query]
        }
    }

    var headers: [String: String] {
        return Environment.baseHeaders
    }

    var body: Any? {
        switch self {
            case .autocomplete:
                return nil
        }
    }
    
    var authentication: Authentication {
        switch self {
            case .autocomplete:
                return .none
        }
    }

    var encoding: EncodingType {
        switch self {
            case .autocomplete:
                return .none
        }
    }

}

extension AsyncNetworkServiceType {

    func addresses(query: String) async throws -> [AddressSuggestionResponse] {
        let endpoint = AddressEndpoint.autocomplete(query: query)
        return try await self.send(endpoint: endpoint)
    }

}
