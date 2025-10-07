import Vapor
import JWT

struct Payload: JWTPayload, Authenticatable {
    // User-releated stuff
    var userID: UUID
    var firstName: String?
    var email: String
    var isAdmin: Bool
    
    // JWT stuff
    var exp: ExpirationClaim
    
    func verify(using signer: JWTSigner) throws {
        try self.exp.verifyNotExpired()
    }
    
    init(with user: User) throws {
        self.userID = try user.requireID()
        self.firstName = user.firstName
        self.email = user.email
        self.isAdmin = user.isAdmin
        self.exp = ExpirationClaim(value: Date().addingTimeInterval(Constants.ACCESS_TOKEN_LIFETIME))
    }
}

extension User {
    convenience init(from payload: Payload) {
        self.init(id: payload.userID, firstName: payload.firstName, email: payload.email, passwordHash: "", isAdmin: payload.isAdmin)
    }
}
