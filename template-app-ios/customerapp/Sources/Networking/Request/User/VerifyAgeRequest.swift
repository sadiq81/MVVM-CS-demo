
import Foundation

struct VerifyAgeRequest: Encodable {
    
    var userinfoToken: String
    var idTokenHint: String
    
    init(userinfoToken: String, idTokenHint: String) {
        self.userinfoToken = userinfoToken
        self.idTokenHint = idTokenHint
    }
    
}
