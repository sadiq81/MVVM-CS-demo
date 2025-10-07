
import Foundation
import Vapor

struct InstallationResponse: Content {
    
    var id: UUID
    
    init(from installation: Installation) throws {
        self.id = try installation.requireID()
    }
}

