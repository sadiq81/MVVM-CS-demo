import Vapor
import Fluent

struct AuthenticationController: RouteCollection {
    
    func boot(routes: RoutesBuilder) throws {
        routes.group("auth") { auth in
            
            auth.post("login", use: self.login)
            auth.post("access-token", use: self.accessToken)
            
            auth.group("reset-password") { resetPasswordRoutes in
                resetPasswordRoutes.post("", use: resetPassword)
            }
            
            auth.group(UserAuthenticator()) { authenticated in
                authenticated.post("logout", use: self.logout)
            }
        }
    }
    
   private func login(_ req: Request) async throws -> LoginResponse {
        
        try LoginRequest.validate(content: req)
        let loginRequest = try req.content.decode(LoginRequest.self)
        
        guard let user = try await req.users.find(email: loginRequest.email) else {
            throw AuthenticationError.invalidEmailOrPassword
        }
        
        guard user.isEmailVerified else {
            throw AuthenticationError.emailIsNotVerified
        }
        
        let verified = try await req.password.async.verify(loginRequest.password, created: user.passwordHash).get()
        guard verified else { throw AuthenticationError.invalidEmailOrPassword }
        
        guard let installation = try await req.installations.find(id: loginRequest.installationId) else {
            throw AuthenticationError.installtionNotFound
        }
        
        installation.$user.id = try user.requireID()
        try await req.installations.update(installation)
        try await req.refreshTokens.delete(for: user.requireID())
        
        let token = req.random.generate(bits: 256)
        let refreshToken = try RefreshToken(token: SHA256.hash(token), userID: user.requireID())
        try await req.refreshTokens.create(refreshToken)
        
        let response = try LoginResponse(accessToken: req.jwt.sign(Payload(with: user)),
                                         refreshToken: token,
                                         accessTokenExpiry: Date().addingTimeInterval(Constants.ACCESS_TOKEN_LIFETIME),
                                         refreshTokenExpiry: refreshToken.expiresAt)
        return response
        
    }
    
    private func accessToken(_ req: Request) async throws -> AccessTokenResponse {
        let accessTokenRequest = try req.content.decode(AccessTokenRequest.self)
        let hashedRefreshToken = SHA256.hash(accessTokenRequest.refreshToken)
        
        guard let refreshToken = try await req.refreshTokens .find(token: hashedRefreshToken) else {
            try await self.resetInstallation(req)
            throw AuthenticationError.refreshTokenOrUserNotFound
        }
        
        try await req.refreshTokens.delete(refreshToken)
        guard refreshToken.expiresAt > Date() else {
            try await self.resetInstallation(req)
            throw AuthenticationError.refreshTokenHasExpired
        }
        
        guard let user = try await req.users.find(id: refreshToken.$user.id) else {
            try await self.resetInstallation(req)
            throw AuthenticationError.refreshTokenOrUserNotFound
        }
        
        let token = req.random.generate(bits: 256)
        let newRefreshToken = try RefreshToken(token: SHA256.hash(token), userID: user.requireID())
        
        let payload = try Payload(with: user)
        let accessToken = try req.jwt.sign(payload)
        
        try await req.refreshTokens.create(newRefreshToken)
        
        let response = AccessTokenResponse(accessToken: accessToken,
                                           refreshToken: token,
                                           accessTokenExpiry: payload.exp.value,
                                           refreshTokenExpiry: refreshToken.expiresAt)
        return response
    }
    
    private func resetPassword(_ req: Request) async throws -> HTTPStatus {
        
        let resetPasswordRequest = try req.content.decode(ResetPasswordRequest.self)
        
        guard let user = try await req.users.find(email: resetPasswordRequest.email) else {
            return .noContent
        }
            
        try await req.passwordResetter.reset(for: user)
        
        return .noContent
    }
    
    private func logout(_ req: Request) async throws -> HTTPStatus {
        
        let payload = try req.auth.require(Payload.self)
        
        try LogoutRequest.validate(content: req)
        let logoutRequest = try req.content.decode(LogoutRequest.self)
        
        try await req.refreshTokens.delete(for: payload.userID)
        
        guard let installation: Installation = try await req.installations.find(id: logoutRequest.installationId) else {
            return .noContent
        }
        installation.$user.id = nil
        try await req.installations.update(installation)
        
        return .ok
        
    }
    
    private func resetInstallation(_ req: Request) async throws {
        let accessTokenRequest = try req.content.decode(AccessTokenRequest.self)
        guard let installation = try? await req.installations.find(id: accessTokenRequest.installationId) else { return }
        installation.$user.id = nil
        try? await req.installations.update(installation)
    }

}
