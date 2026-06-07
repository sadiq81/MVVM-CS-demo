import Combine
import SafariServices
import SwiftUI
import UIKit

import MustacheServices
import MustacheUIKit

@MainActor
final class MoreCoordinator: NSObject, UIKitCoordinatorType {

    var baseController: UIViewController? { self.navigationController }

    weak var navigationController: UINavigationController?
    weak var parent: (any CoordinatorType)?

    var children = NSHashTable<AnyObject>.weakObjects()

    @Injected(\.secureStorageService)
    private var secureStorageService: any SecureStorageServiceType

    @Injected(\.userService)
    private var userService: any UserServiceType

    private var cancellables = Set<AnyCancellable>()

    init(parent: any CoordinatorType, navigationController: UINavigationController) {
        self.parent = parent
        self.navigationController = navigationController
        super.init()
        self.configure()
    }

    func start() throws {
        try self.transition(to: MoreTransition.root)
    }

    func stop() throws {}

    func route(to route: Route) {}

    func transition(to transition: MustacheServices.Transition) throws {
        if let transition = transition as? MoreTransition {
            switch transition {
                case .root:
                    let controller = MoreView().hosted(by: self)
                    self.navigationController?.setViewControllers([controller], animated: false)

                case .profile:
                    let controller = UserProfileView().hosted(by: self)
                    self.navigationController?.pushViewController(controller, animated: true)

                case .password:
                    let controller = PasswordView().hosted(by: self)
                    self.navigationController?.pushViewController(controller, animated: true)

                case .pop:
                    self.navigationController?.popViewController(animated: true)

                
                case .countryPicker(let mode):
                    let controller = CountryPickerView(mode: mode).hosted(by: self)
                    self.navigationController?.present(controller, animated: true)

                case .addressSearch:
                    let controller = AddressSearchView().hosted(by: self)
                    self.navigationController?.present(controller, animated: true)

                case .secureContent:
                    
                    let coordinator = PinCoordinator(parent: self, navigationController: self.navigationController)

                    if self.secureStorageService.dataStoredWithPin {
                        try coordinator.transition(to: PinTransition.validate(self))
                    } else {
                        guard let secret = "some-secret".data(using: .utf8) else { return }
                        try coordinator.transition(to: PinTransition.enroll(self, secret))
                    }

                case .validateAge:
                    let coordinator = OIDAuthorizationCoordinator(parent: self, navigationController: self.navigationController)
                    try coordinator.transition(to: OIDAuthorizationTransition.validateAge(presenter: self.navigationController))

                case .removeVerification:
                    Task {
                        do {
                            try await self.userService.removeVerification()
                        } catch {
                            if let presenter = self.navigationController?.topViewController {
                                UIAlertController.alert(title: Strings.Error.Generic.title, message: error.localizedDescription)
                                    .action(title: Strings.Button.ok)
                                    .present(in: presenter)
                            }
                        }
                    }

                case .webview(let url):
                    let controller = SFSafariViewController(url: url)
                    controller.preferredBarTintColor = Colors.Foreground.brand.color
                    controller.preferredControlTintColor = Colors.Foreground.light.color
                    self.navigationController?.present(controller, animated: true)

                case .dismiss:
                    self.navigationController?.dismiss(animated: true)
            }
        } else {
            try self.parent?.transition(to: transition)
        }
    }

    private func configure() {
        self.navigationController?.tabBarItem = UITabBarItem(title: Strings.Tabbar.more, image: UIImage(systemName: Images.System.more), tag: 3)
    }

    deinit {
        debugPrint("deinit \(self)")
    }
}

// MARK: - CoordinatorDelegate

extension MoreCoordinator: @preconcurrency CoordinatorDelegate {

    func completed(child: (any CoordinatorType)?, completion: (any Completion)?) {
        // OID authorization completed — user profile will auto-refresh via userPublisher
    }
}

// MARK: - PinDelegate

extension MoreCoordinator: PinDelegate {

    func didEnroll(data: Data) {
        self.didAuthenticate(data: data)
    }

    func didFail(with error: Error) {
        if let presenter = self.navigationController?.topViewController {
            UIAlertController.alert(title: "PinDelegate", message: "didFail")
                .action(title: Strings.Button.ok)
                .present(in: presenter)
        }
    }

    func didAuthenticate(data: Data) {
        let secretViewModel = Container.shared.secretViewModel()
        secretViewModel.data = data
        let controller = SecretView().hosted(by: self)
        controller.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(controller, animated: true)
    }

    func didCancel() {
        if let presenter = self.navigationController?.topViewController {
            UIAlertController.alert(title: "PinDelegate", message: "didCancel")
                .action(title: Strings.Button.ok)
                .present(in: presenter)
        }
    }
}
