import Vapor

struct AppConfig {

    let frontendURL: String
    let apiURL: String
    let noReplyEmail: String
    let mitidBrokerUserinfoURL: String

    static var environment: AppConfig {
        guard
            let frontendURL = Environment.get("SITE_FRONTEND_URL"),
            let apiURL = Environment.get("SITE_API_URL"),
            let noReplyEmail = Environment.get("NO_REPLY_EMAIL")
            else {
                fatalError("Please add app configuration to environment variables")
        }

        let mitidBrokerUserinfoURL = Environment.get("MITID_BROKER_USERINFO_URL") ?? "https://pp.netseidbroker.dk/op/connect/userinfo"

        return .init(frontendURL: frontendURL, apiURL: apiURL, noReplyEmail: noReplyEmail, mitidBrokerUserinfoURL: mitidBrokerUserinfoURL)
    }
}

extension Application {
    
    struct AppConfigKey: StorageKey {
        typealias Value = AppConfig
    }
    
    var config: AppConfig {
        get {
            storage[AppConfigKey.self] ?? .environment
        }
        set {
            storage[AppConfigKey.self] = newValue
        }
    }
}
