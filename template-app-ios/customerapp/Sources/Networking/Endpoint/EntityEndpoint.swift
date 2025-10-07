import Foundation
import MustacheFoundation
import MustacheServices

enum EntityEndpoint {

    case list
    case update(EntityModel)
    case delete(EntityModel)

    case search(filter1: String, filter2: String, page: Int?, size: Int?)
    case create(EntityModel)

}

extension EntityEndpoint: Endpoint {

    var baseURL: URL {
        return Environment.backendURL
    }

    var method: RequestType {
        switch self {
            case .list:
                return .get
            case .update:
                return .put
            case .delete:
                return .delete

            case .search:
                return .get
            case .create:
                return .post
        }
    }

    var parameters: [String: String]? {
        switch self {
            case .search(let filter1, let filter2, let page, let size):
                var parameters = ["filter1": filter1, "filter2": filter2]
                if let page, let size {
                    parameters["page"] = "\(page)"
                    parameters["size"] = "\(size)"
                }
                return parameters
            default:
                return nil
        }
    }

    var path: String {
        switch self {
            case .list:
                return "/entity/me"
            case .update(let entity):
                return "/entity/\(entity.id)"
            case .delete(let entity):
                return "/entity/\(entity.id)"
            case .search:
                return "/entity"
            case .create:
                return "/entity/me"
        }
    }

    var headers: [String: String] {
        return Environment.baseHeaders
    }

    var body: Any? {
        switch self {
            case .create(let entity):
                return EntityRequest(entity: entity)
            case .update(let entity):
                return EntityRequest(entity: entity)
            default:
                return nil
        }
    }

    var encoding: EncodingType {
        switch self {
            case .create:
                return .json
            default:
                return .none
        }
    }

    var authentication: Authentication {
        return .oauth
    }

}

extension AsyncNetworkServiceType {

    func entities() async throws -> [EntityResponse] {
        let endpoint = EntityEndpoint.list
        return try await self.send(endpoint: endpoint, using: .yyyyMMddTHHmmss)
    }

    func update(_ model: EntityModel) async throws -> EntityResponse {
        let endpoint = EntityEndpoint.update(model)
        return try await self.send(endpoint: endpoint, using: .yyyyMMddTHHmmss)
    }

    func delete(_ model: EntityModel) async throws -> EmptyReply {
        let endpoint = EntityEndpoint.delete(model)
        return try await self.send(endpoint: endpoint, using: .yyyyMMddTHHmmss)
    }

    func create(_ model: EntityModel) async throws -> EntityResponse {
        let endpoint = EntityEndpoint.create(model)
        return try await self.send(endpoint: endpoint, using: .yyyyMMddTHHmmss)
    }

    func search(filter1: String, filter2: String, page: Int?, size: Int?) async throws -> EntityPaginatedResponse {
        let endpoint = EntityEndpoint.search(filter1: filter1, filter2: filter2, page: page, size: size)
        return try await self.send(endpoint: endpoint, using: .yyyyMMddTHHmmss)
    }
}
