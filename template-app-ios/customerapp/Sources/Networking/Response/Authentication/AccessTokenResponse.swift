import Foundation

struct AccessTokenResponse: Decodable {

    var accessToken: String
    var refreshToken: String
    var accessTokenExpiry: Date
    var refreshTokenExpiry: Date

}
