import Foundation

import MustacheFoundation
import MustacheServices

enum AuthenticationEndpoint {

    case register(RegisterRequest)
    case login(LoginRequest)
    case accessToken(AccessTokenRequest)
    case resetPassword(ResetPasswordRequest)
    case logout(LogoutRequest)

}

extension AuthenticationEndpoint: Endpoint {

    var baseURL: URL {
        return Environment.backendURL
    }

    var method: RequestType {
        switch self {
            default:
                return .post
        }
    }

    var path: String {
        switch self {
            case .register:
                return "/auth/register"
            case .login:
                return "/auth/login"
            case .accessToken:
                return "/auth/access-token"
            case .resetPassword:
                return "/auth/reset-password"
            case .logout:
                return "/auth/logout"
        }
    }

    var headers: [String: String] { return Environment.baseHeaders }

    var body: Any? {
        switch self {
            case .register(let request):
                return request
            case .login(let request):
                return request
            case .accessToken(let request):
                return request
            case .resetPassword(let request):
                return request
            case .logout(let request):
                return request
        }
    }
    
//    var demoData: Decodable? {
//        switch self {
//            case .register:
//                return EmptyReply()
//            case .login:
//                return LoginResponse.mockData
//            case .accessToken:
//                return AccessTokenResponse.mockData
//            case .resetPassword:
//                return EmptyReply()
//            case .logout:
//                return EmptyReply()
//        }
//    }

    var authentication: Authentication {
        switch self {
            case .logout:
                return .oauth
            default:
                return .none
            }
    }

    var encoding: EncodingType {
        return .json()
    }

}

extension AsyncNetworkServiceType {

    func register(request: RegisterRequest) async throws -> EmptyReply {
        let endpoint = AuthenticationEndpoint.register(request)
        return try await self.send(endpoint: endpoint)
    }

    func login(request: LoginRequest) async throws -> LoginResponse {
        let endpoint = AuthenticationEndpoint.login(request)
        return try await self.send(endpoint: endpoint)
    }

    func accessToken(request: AccessTokenRequest) async throws -> AccessTokenResponse {
        let endpoint = AuthenticationEndpoint.accessToken(request)
        return try await self.send(endpoint: endpoint)
    }

    @discardableResult
    func resetPassword(request: ResetPasswordRequest) async throws -> EmptyReply {
        let endpoint = AuthenticationEndpoint.resetPassword(request)
        return try await self.send(endpoint: endpoint)
    }

    @discardableResult
    func logout(request: LogoutRequest) async throws -> EmptyReply {
        let endpoint = AuthenticationEndpoint.logout(request)
        return try await self.send(endpoint: endpoint)
    }

}


extension AsyncNetworkService: @retroactive RefreshTokenServiceType {

    nonisolated public func endpoint(refreshToken: String) throws -> Endpoint {
        let service = Resolver.resolve(InstallationServiceType.self)
        guard let installationId = service.installationId else { throw InstallationError.missingInstallationId }
        let request = AccessTokenRequest(refreshToken: refreshToken, installationId: installationId)
        let endpoint = AuthenticationEndpoint.accessToken(request)
        return endpoint
    }

    nonisolated public func token(for data: Data) throws -> AuthToken {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let authResponse = try decoder.decode(LoginResponse.self, from: data)
        let token = AuthToken(response: authResponse)
        return token
    }
}

enum InstallationError: Swift.Error {
    case missingInstallationId
}


