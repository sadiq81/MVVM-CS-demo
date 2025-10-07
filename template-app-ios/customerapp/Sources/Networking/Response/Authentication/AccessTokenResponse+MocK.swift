import Foundation

extension AccessTokenResponse {
    
    static let mockData = AccessTokenResponse(accessToken: "accessToken",
                                        refreshToken: "refreshToken",
                                        accessTokenExpiry: Date().addingTimeInterval(60*60),
                                        refreshTokenExpiry: Date().addingTimeInterval(60*60*90))
}
