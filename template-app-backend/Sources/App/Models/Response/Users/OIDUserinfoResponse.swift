
import Vapor

struct OIDUserinfoResponse: Content {
    
    var cpr: String
    var sub: UUID
    
    enum CodingKeys: String, CodingKey {
        case cpr = "dk.cpr"
        case sub
    }
}
