

import Foundation
import AppAuth

extension OIDAuthState {
    
    static func authState(for request: OIDAuthorizationRequest, in viewController: UIViewController) async throws -> (OIDExternalUserAgentSession, OIDAuthState)? {
        
        return try await withCheckedThrowingContinuation({ (continuation: CheckedContinuation<(OIDExternalUserAgentSession, OIDAuthState)?, Error>) in
            
            var session: OIDExternalUserAgentSession!
            session = OIDAuthState.authState(byPresenting: request, presenting: viewController) { authState, error in
                if let authState = authState {
                    continuation.resume(returning: (session, authState))
                } else if let error = error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume(returning: nil)
                }
            }
        })
    }
}
                                                         
