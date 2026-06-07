
import Combine
import Foundation
import UIKit

import AppAuth
import MustacheFoundation
import MustacheServices

@MainActor
final class OIDAuthorizationViewModel: ObservableObject {

    // MARK: - State

    @Published var isLoading: Bool = true
    @Published var isFinished: Bool = false
    @Published var showError: Bool = false
    @Published var errorMessage: String = ""

    // MARK: - Services

    @Injected(\.userService)
    private var userService: any UserServiceType

    // MARK: - Private

    private var currentAuthorizationFlow: OIDExternalUserAgentSession?
    private var currentAuthState: OIDAuthState?

    // MARK: - Functions

    func startAuthorization(from presenter: UIViewController) {
        Task { @MainActor in
            do {
                guard let configuration = try await OIDAuthorizationService.discoverConfiguration(for: MustacheFoundation.Environment.openIdIssuerUrl) else {
                    self.isFinished = true
                    return
                }

                let request = OIDAuthorizationRequest(
                    configuration: configuration,
                    clientId: MustacheFoundation.Environment.openIdClientId,
                    clientSecret: MustacheFoundation.Environment.openIdClientSecret,
                    scopes: [OIDScopeOpenID, "ssn"],
                    redirectURL: .openIdRedirect,
                    responseType: OIDResponseTypeCode,
                    additionalParameters: ["prompt": "login"]
                )

                guard let result = try await OIDAuthState.authState(for: request, in: presenter) else {
                    self.isFinished = true
                    return
                }

                self.currentAuthorizationFlow = result.session
                self.currentAuthState = result.state

                guard let userInfoToken = result.state.lastTokenResponse?.accessToken,
                      let idToken = result.state.lastTokenResponse?.idToken else {
                    self.isFinished = true
                    return
                }

                self.currentAuthorizationFlow = nil
                self.currentAuthState = nil

                // Verify age on the backend
                try await self.userService.verifyAge(userInfoToken: userInfoToken, idToken: idToken)
                self.isFinished = true

            } catch {
                self.isLoading = false
                self.errorMessage = error.localizedDescription
                self.showError = true
            }
        }
    }

    deinit {
        debugPrint("deinit \(self)")
    }
}
