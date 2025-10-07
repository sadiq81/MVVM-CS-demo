import Foundation
import MustacheFoundation
import MustacheServices

public actor MemoryCredentialsServiceType: AsyncCredentialsServiceType {
    
    public static var accessibility: KeychainItemAccessibility = .afterFirstUnlock
    
    @SingletonOptional(CredentialType.username.rawValue)
    var username: String?
    
    @SingletonOptional(CredentialType.password.rawValue)
    var password: String?
    
    @SingletonOptional(CredentialType.bearer.rawValue)
    var bearer: String?
    
    @SingletonOptional(CredentialType.oauth.rawValue)
    var oauthToken: AuthToken?
    
    public init() { }
    
    public func getCredential<T>(type: CredentialType) async -> T? where T : Credential {
        switch type {
            case .username:
                return self.username as? T
            case .password:
                return self.password as? T
            case .bearer:
                return self.bearer as? T
            case .oauth:
                return self.oauthToken as? T
        }
    }
    
    public func setCredential(type: MustacheServices.CredentialType, value: MustacheServices.Credential?) async {
        switch (type, value) {
            case (.username, let value as String):
                self.username = value
            case (.username, .none):
                self.username = nil
                
            case (.password, let value as String):
                self.password = value
            case (.password, .none):
                self.password = nil
                
            case (.bearer, let value as String):
                self.bearer = value
            case (.bearer, .none):
                self.bearer = nil
                
            case (.oauth, let value as AuthToken):
                self.oauthToken = value
            case (.oauth, .none):
                self.oauthToken = nil
                
            default:
                break
        }
    }
    
    public func invalidate(type: CredentialType) async {
        switch type {
            case .username:
                self.username = nil
            case .password:
                self.password = nil
            case .bearer:
                self.bearer = nil
            case .oauth:
                guard let old = self.oauthToken else { return }
                self.oauthToken = AuthToken(accessToken: "expired",
                                            accessTokenExpiration: Date.distantPast,
                                            refreshToken: old.refreshToken)
        }
        
    }
    
    public func invalidate() async {
        for type in CredentialType.allCases {
            await self.invalidate(type: type)
        }
        
    }
    
    public func clearState() async {
        self.username = nil
        self.password = nil
        self.bearer = nil
        self.oauthToken = nil
    }
    
}
