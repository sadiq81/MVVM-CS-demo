
import Foundation
import MustacheServices

struct LoginResponse: Decodable {

    let accessToken: String
    let refreshToken: String
    var accessTokenExpiry: Date
    var refreshTokenExpiry: Date

}


