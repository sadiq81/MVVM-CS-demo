
import Foundation

extension LoginResponse {
    
   static let mockData = LoginResponse(accessToken: "accessToken",
                                       refreshToken: "refreshToken",
                                       accessTokenExpiry: Date().addingTimeInterval(60*60),
                                       refreshTokenExpiry: Date().addingTimeInterval(60*60*90))
    
}

