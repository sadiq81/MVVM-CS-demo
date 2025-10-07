
import Foundation
import AppAuth

extension OIDAuthorizationService {
    
    static func discoverConfiguration(for issuer: URL) async throws -> OIDServiceConfiguration? {
                
        return try await withCheckedThrowingContinuation({ (continuation: CheckedContinuation<OIDServiceConfiguration?, Error>) in
            
            OIDAuthorizationService.discoverConfiguration(forIssuer: issuer) { configuration, error in
                if let configuration = configuration {
                    continuation.resume(returning: configuration)
                } else if let error = error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume(returning: nil)
                }
            }
        })
            
    }
    
    static func present(request: OIDEndSessionRequest, externalUserAgent: OIDExternalUserAgent) async throws -> (OIDExternalUserAgentSession?, OIDEndSessionResponse?)? {
       
        return try await withCheckedThrowingContinuation({ (continuation: CheckedContinuation<(OIDExternalUserAgentSession?, OIDEndSessionResponse?)?, Error>) in
            
            var session: OIDExternalUserAgentSession!
            session = OIDAuthorizationService.present(request, externalUserAgent: externalUserAgent, callback: { response, error in
                if let response = response {
                    continuation.resume(returning: (session, response))
                    
                } else if let error = error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume(returning: nil)
                }
            })
        })
        
    }
    
}
