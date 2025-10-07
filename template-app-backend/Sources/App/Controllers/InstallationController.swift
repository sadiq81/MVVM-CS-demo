import Vapor
import Fluent

struct InstallationController: RouteCollection {
    
    
    func boot(routes: RoutesBuilder) throws {
        
        routes.group("installation") { installation in
            
            installation.post("", use: self.installationGenerator)
            
            installation.group(UserAuthenticator()) { authenticated in
                authenticated.put(":id", "device-token", use: self.deviceToken)
            }
        }
    }
    
    private func installationGenerator(_ req: Request) async throws -> InstallationResponse {
        
        try InstallationRequest.validate(content: req)
        let request = try req.content.decode(InstallationRequest.self)
        let installation = Installation(from: request)
        
        try await req.installations.create(installation)
        
        let response = try InstallationResponse(from: installation)
        return response
    }
    
    private func deviceToken(_ req: Request) async throws -> HTTPStatus {
        let payload = try req.auth.require(Payload.self)
        
        guard let uuidString = req.parameters.get("id"), let uuid = UUID(uuidString: uuidString) else {
            throw Abort(.badRequest, reason: "missing Installation id")
        }

        let fmcTokenRequest = try req.content.decode(FCMTokenRequest.self)
        
        guard let installation = try await req.installations.find(id: uuid) else {
            throw Abort(.notFound)
        }
        
        installation.fcmToken = fmcTokenRequest.token
        installation.$user.id = payload.userID
        
        try await req.installations.update(installation)

        return .ok
    }
    
}
