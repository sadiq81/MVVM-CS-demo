import Foundation

import AppAuth

private struct UncheckedSendableBox<T>: @unchecked Sendable {
    let value: T
}

extension OIDAuthorizationService {

    static func discoverConfiguration(for issuer: URL) async throws -> OIDServiceConfiguration? {

        let box = try await withCheckedThrowingContinuation({ (continuation: CheckedContinuation<UncheckedSendableBox<OIDServiceConfiguration?>, Error>) in

            OIDAuthorizationService.discoverConfiguration(forIssuer: issuer) { configuration, error in
                if let configuration = configuration {
                    continuation.resume(returning: UncheckedSendableBox(value: configuration))
                } else if let error = error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume(returning: UncheckedSendableBox(value: nil))
                }
            }
        })
        return box.value

    }

    static func present(request: OIDEndSessionRequest, externalUserAgent: OIDExternalUserAgent) async throws -> (OIDExternalUserAgentSession?, OIDEndSessionResponse?)? {

        let box = try await withCheckedThrowingContinuation({ (continuation: CheckedContinuation<UncheckedSendableBox<(OIDExternalUserAgentSession?, OIDEndSessionResponse?)?>, Error>) in

            nonisolated(unsafe) var session: OIDExternalUserAgentSession!
            session = OIDAuthorizationService.present(request, externalUserAgent: externalUserAgent, callback: { response, error in
                if let response = response {
                    continuation.resume(returning: UncheckedSendableBox(value: (session, response)))

                } else if let error = error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume(returning: UncheckedSendableBox(value: nil))
                }
            })
        })
        return box.value

    }

}
