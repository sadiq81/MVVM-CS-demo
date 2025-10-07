
import Foundation
import UIKit
import SafariServices

import MustacheFoundation
import MustacheServices

import AppAuth

protocol OIDAuthorizationCoordinatorType: CoordinatorType {
    
}

class OIDAuthorizationCoordinator: NSObject, OIDAuthorizationCoordinatorType {
    
    var baseController: UIViewController? { self.navigationController }
    weak var navigationController: UINavigationController?
    
    var currentAuthorizationFlow: OIDExternalUserAgentSession?
    var currentAuthState: OIDAuthState?
    
    @Injected
    fileprivate var userService: UserServiceType
    
    @Injected
    fileprivate var loggingService: LoggingServiceType
    
    weak var parent: CoordinatorDelegate?
    
    init(parent: CoordinatorDelegate, navigationController: UINavigationController?) {
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
                    Task {  @MainActor in
                        do {
                            guard let configuration = try await OIDAuthorizationService.discoverConfiguration(for: Environment.openIdIssuerUrl) else { return }
                            
                            let request = OIDAuthorizationRequest(configuration: configuration,
                                                                  clientId: Environment.openIdClientId,
                                                                  clientSecret: Environment.openIdClientSecret,
                                                                  scopes: [OIDScopeOpenID, "ssn"],
                                                                  redirectURL: .openIdRedirect,
                                                                  responseType: OIDResponseTypeCode,
                                                                  additionalParameters: ["prompt": "login"]) // Forces login every time
                            
                            guard let presenter = presenter else { return }
                            guard let sessionState = try await OIDAuthState.authState(for: request, in: presenter) else { return }
                            
                            self.currentAuthorizationFlow = sessionState.0
                            self.currentAuthState = sessionState.1
                            
                            guard let userInfoToken = sessionState.1.lastTokenResponse?.accessToken else { return }
                            guard let idToken = sessionState.1.lastTokenResponse?.idToken else { return }
                            
                            try await self.userService.verifyAge(userInfoToken: userInfoToken, idToken: idToken)
                            
                            self.currentAuthorizationFlow = nil
                            self.currentAuthState = nil
                            
                            self.parent?.completed(child: self)
                        } catch let error {
                            debugPrint("error: \(error)")
                        }
                        
                        presenter?.dismiss(animated: true, completion: nil)
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
