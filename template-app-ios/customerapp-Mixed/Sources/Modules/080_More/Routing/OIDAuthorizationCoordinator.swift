import Combine
import Foundation
import SafariServices
import UIKit

import MustacheFoundation
import MustacheServices

import AppAuth

@MainActor
final class OIDAuthorizationCoordinator: NSObject, UIKitCoordinatorType {

    var baseController: UIViewController? { self.navigationController }
    weak var navigationController: UINavigationController?

    var currentAuthorizationFlow: OIDExternalUserAgentSession?
    var currentAuthState: OIDAuthState?

    @Injected(\.userService)
    fileprivate var userService: any UserServiceType

    @Injected(\.loggingService)
    fileprivate var loggingService: any LoggingServiceType

    weak var parent: (any CoordinatorDelegate)?
    private var selfReference: (any CoordinatorType)?

    init(parent: any CoordinatorDelegate, navigationController: UINavigationController?) {
        self.parent = parent
        self.navigationController = navigationController
        super.init()
    }

    func start() throws {}

    func stop() throws {
        self.parent?.completed(child: self)
    }

    func transition(to transition: Transition) throws {
        if let transition = transition as? OIDAuthorizationTransition {
            switch transition {
                case .validateAge(let presenter):
                    Task { @MainActor in
                        self.selfReference = self

                        do {
                            guard let configuration = try await OIDAuthorizationService.discoverConfiguration(for: Environment.openIdIssuerUrl) else { return }

                            let request = OIDAuthorizationRequest(configuration: configuration,
                                                                  clientId: Environment.openIdClientId,
                                                                  clientSecret: Environment.openIdClientSecret,
                                                                  scopes: [OIDScopeOpenID, "ssn"],
                                                                  redirectURL: .openIdRedirect,
                                                                  responseType: OIDResponseTypeCode,
                                                                  additionalParameters: ["prompt": "login"])

                            guard let presenter = presenter else { return }
                            guard let result = try await OIDAuthState.authState(for: request, in: presenter) else { return }

                            self.currentAuthorizationFlow = result.session
                            self.currentAuthState = result.state

                            guard let userInfoToken = result.state.lastTokenResponse?.accessToken else { return }
                            guard let idToken = result.state.lastTokenResponse?.idToken else { return }

                            try await self.userService.verifyAge(userInfoToken: userInfoToken, idToken: idToken)

                            self.currentAuthorizationFlow = nil
                            self.currentAuthState = nil

                            self.parent?.completed(child: self)
                        } catch {
                            guard (error as NSError).domain != "org.openid.appauth.general" && (error as NSError).code != -1 else { return }
                            debugPrint("OID error: \(error)")
                        }

                        presenter?.dismiss(animated: true, completion: nil)
                        self.selfReference = nil
                    }
            }
        } else {
            try self.parent?.transition(to: transition)
        }
    }

    func route(to route: Route) {}
}

enum OIDAuthorizationTransition: Transition {
    case validateAge(presenter: UINavigationController?)
}
