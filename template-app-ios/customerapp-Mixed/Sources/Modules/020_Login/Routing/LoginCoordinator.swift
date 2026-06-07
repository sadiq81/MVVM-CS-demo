import Combine
import SwiftUI
import UIKit

import MustacheServices
import MustacheUIKit

@MainActor
final class LoginCoordinator: NSObject, UIKitCoordinatorType, Completion {

    var baseController: UIViewController? { self.navigationController }

    weak var navigationController: UINavigationController?
    weak var parent: (any CoordinatorType)?

    var children = NSHashTable<AnyObject>.weakObjects()

    @Injected(\.loginService)
    private var loginService: any LoginServiceType

    private var cancellables = Set<AnyCancellable>()

    init(parent: any CoordinatorType, navigationController: UINavigationController) {
        self.parent = parent
        self.navigationController = navigationController
        super.init()
    }

    func start() throws {
        try self.transition(to: LoginTransition.root)
    }

    func stop() throws {}

    func route(to route: Route) {}

    func transition(to transition: MustacheServices.Transition) throws {
        if let transition = transition as? LoginTransition {
            switch transition {
                case .root:
                    let controller = LoginView().hosted(by: self)
                    self.navigationController?.setViewControllers([controller], animated: false)
                case .showForgotPassword:
                    let controller = ForgotPasswordView().hosted(by: self)
                    self.navigationController?.pushViewController(controller, animated: true)
                case .dismissForgotPassword:
                    self.navigationController?.popViewController(animated: true)
                case .showSignup:
                    let controller = SignupView().hosted(by: self)
                    self.navigationController?.pushViewController(controller, animated: true)
                case .dismissSignup:
                    self.navigationController?.popViewController(animated: true)
                case .loginCompleted:
                    try self.parent?.stop(with: self)
                }
        } else {
            try self.parent?.transition(to: transition)
        }
    }

    deinit {
        debugPrint("deinit \(self)")
    }
}

// MARK: - Login Transition

enum LoginTransition: MustacheServices.Transition {
    case root
    case showForgotPassword
    case dismissForgotPassword
    case showSignup
    case dismissSignup
    case loginCompleted
}
