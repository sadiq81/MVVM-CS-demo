import MustacheFoundation
import MustacheServices
import MustacheUIKit
import SafariServices

class MoreCoordinator: NSObject, CoordinatorType {
    
    var baseController: UIViewController? { return self.navigationController }
    
    weak var navigationController: UINavigationController?
    weak var parent: CoordinatorType?
    
    @Injected
    private var secureStorage: SecureStorageServiceType
    
    @Injected
    var loggingService: LoggingServiceType
    
    init(parent: CoordinatorType, navigationController: UINavigationController) {
        self.parent = parent
        self.navigationController = navigationController
        super.init()
    }
    
    func start() throws {
        let controller = AppStoryboard.viewController(class: MoreViewController.self)
        controller.coordinator = self
        self.navigationController?.viewControllers = [controller]
    }
    
    func stop() throws {}
    
    func route(to route: Route) {}
    
    deinit {
        debugPrint("deinit \(self)")
    }
    
}

enum MoreTransition: Transition {
    case profile
    case password
    case countryPicker(delegate: CountryPickerDelegate)
    case addressPicker(delegate: AddressSearchDelegate)
    case secureContent
    case webview(url: URL)
}

extension MoreCoordinator {
    
    func transition(to transition: Transition) throws {
        
        if let transition = transition as? MoreTransition {
            switch transition {
                case .profile:
                    let controller = AppStoryboard.viewController(class: UserViewController.self)
                    controller.coordinator = self
                    self.navigationController?.pushViewController(controller, animated: true)
                    self.loggingService.log(event: .profile)
                    
                case .password:
                    let controller = AppStoryboard.viewController(class: PasswordViewController.self)
                    controller.coordinator = self
                    self.navigationController?.pushViewController(controller, animated: true)
                    
                case .countryPicker(let delegate):
                    let controller = AppStoryboard.viewController(class: CountryPickerViewController.self)
                    controller.coordinator = self
                    controller.delegate = delegate
                    
                    let navigationController = UINavigationController(rootViewController: controller)
                    
                    self.navigationController?.present(navigationController, animated: true)
                
                case .addressPicker(let delegate):
                    
                    let controller = AppStoryboard.viewController(class: AddressSearchViewController.self)
                    controller.coordinator = self
                    controller.delegate = delegate
                    
                    let navigationController = UINavigationController(rootViewController: controller)
                    
                    self.navigationController?.present(navigationController, animated: true)
    
                case .secureContent:
    
                    let coordinator = PinCoordinator(parent: self, navigationController: self.navigationController)
    
                    if self.secureStorage.dataStoredWithPin {
                        // If we already have a pin, we can validate it
                        try coordinator.transition(to: PinTransition.validate(self))
                    } else {
                        // The secret could come from an api or user input which we the must guard using the keychain
                        guard let secret = "some-secret".data(using: .utf8) else { return }
                        try coordinator.transition(to: PinTransition.enroll(self, secret))
                    }
                    
                case .webview(let url):
                    
                    let controller = SFSafariViewController(url: url)
                    controller.delegate = Resolver.optional()  // See AppCoordinator
                    controller.preferredBarTintColor = Colors.Foreground.brand.color
                    controller.preferredControlTintColor = UIColor.white
                    self.navigationController?.present(controller, animated: true)
                    
            }
        } else {
            try self.parent?.transition(to: transition)
        }
    }
    
}

extension MoreCoordinator: PinDelegate {

    func didEnroll(data: Data) {
        self.didAuthenticate(data: data)
    }

    func didFail(with error: Error) {
        self.navigationController?.topViewController?.alert(title: "PinDelegate", message: "didFail")
    }

    func didAuthenticate(data: Data) {

        // Callback from LocalAuthentication does not happen on main thread
        DispatchQueue.main.async {

            var viewModel = Resolver.resolve(SecretViewModelType.self)
            viewModel.data = data

            let controller = AppStoryboard.viewController(class: SecretViewController.self)
            self.navigationController?.pushViewController(controller, animated: true)
        }
    }

    func didChangePin() {
        self.navigationController?.topViewController?.alert(title: "PinDelegate", message: "didChangePin")
    }

    func didCancel() {
        self.navigationController?.topViewController?.alert(title: "PinDelegate", message: "didCancel")
    }
}
