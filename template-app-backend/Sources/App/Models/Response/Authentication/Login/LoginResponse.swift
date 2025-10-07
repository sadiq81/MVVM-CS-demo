import Vapor

struct LoginResponse: Content {
    
    let accessToken: String
    let refreshToken: String
    let accessTokenExpiry: Date
    let refreshTokenExpiry: Date
}
