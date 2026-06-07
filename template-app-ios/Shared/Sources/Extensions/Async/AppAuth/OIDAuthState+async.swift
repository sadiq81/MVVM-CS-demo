import Foundation

import AppAuth

extension OIDAuthState {
    
    static func authState(for request: OIDAuthorizationRequest, in viewController: UIViewController) async throws -> AuthStateResult? {
        
        return try await withCheckedThrowingContinuation({ (continuation: CheckedContinuation<AuthStateResult?, Error>) in
            
            var session: OIDExternalUserAgentSession!
            session = OIDAuthState.authState(byPresenting: request, presenting: viewController) { authState, error in
                if let authState = authState {
                    continuation.resume(returning: AuthStateResult(session: session, state: authState))
                } else if let error = error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume(returning: nil)
                }
            }
        })
    }
}

struct AuthStateResult: @unchecked Sendable {
    let session: OIDExternalUserAgentSession
    let state: OIDAuthState
}
                                                         
