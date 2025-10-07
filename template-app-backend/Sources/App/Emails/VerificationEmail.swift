import Vapor

struct VerificationEmail: Email {
    
    let templateName: String = "email_verification"
    
    var templateData: [String : String] {
        ["verify_url": verifyUrl]
    }
    
    var subject: String {
        "Please verify your email"
    }
    
    let verifyUrl: String
    
    init(verifyUrl: String) {
        self.verifyUrl = verifyUrl
    }
}
