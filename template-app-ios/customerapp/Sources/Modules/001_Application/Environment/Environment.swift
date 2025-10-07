import Foundation
import MustacheFoundation
import MustacheServices

extension Environment {

    // API

    public static var backendURL: URL {
        guard let info = infoForKey("ENVIRONMENT_BACKEND_URL") else { fatalError("missing ENVIRONMENT_BACKEND_URL") }
        guard let url = URL(string: info) else { fatalError("invalid ENVIRONMENT_BACKEND_URL: \(info)") }
        return url
    }

    public static var baseHeaders: [String: String] {
        return ["Content-Type": "application/json"]
    }

    // Open ID
    
    public static var openIdIssuerUrl: URL {
        guard let info = infoForKey("ENVIRONMENT_OPEN_ID_ISSUER_URL") else { fatalError("missing ENVIRONMENT_OPEN_ID_ISSUER_URL") }
        guard let url = URL(string: info) else { fatalError("invalid ENVIRONMENT_OPEN_ID_ISSUER_URL: \(info)") }
        return url
    }
    
    public static var openIdClientId: String {
        if let info = MustacheFoundation.KeychainWrapper.standard.string(forKey: "open_id_client_id") { return info }
        let info = infoForKey("ENVIRONMENT_OPEN_ID_CLIENT_ID")
        guard let info else { fatalError("missing ENVIRONMENT_OPEN_ID_CLIENT_ID") }
        return info
    }
    
    public static var openIdClientSecret: String {
        if let info = MustacheFoundation.KeychainWrapper.standard.string(forKey: "open_id_client_secret") { return info }
        let info = infoForKey("ENVIRONMENT_OPEN_ID_CLIENT_SECRET")
        guard let info else { fatalError("missing ENVIRONMENT_OPEN_ID_CLIENT_SECRET") }
        return info
    }
    
}
