
import MustacheFoundation
import MustacheUIKit
import MustacheServices

class PinCoordinator: NSObject, CoordinatorType {

    var baseController: UIViewController? { return self.navigationController }

    weak var navigationController: UINavigationController?
    weak var parent: CoordinatorType?
    
    @Injected
    private var secureStorageServiceType: SecureStorageServiceType

    @Injected
    private var loggingService: LoggingServiceType

    init(parent: CoordinatorType, navigationController: UINavigationController?) {
        self.parent = parent
        self.navigationController = navigationController
        super.init()
    }

    func start() throws { }

    func stop() throws { }

    func route(to route: Route) { }

    deinit {
        debugPrint("deinit \(self)")
    }

}

enum PinTransition: Transition {
    case enroll(PinDelegate, Data)
    case validate(PinDelegate)
    case changePin(PinDelegate)
}

extension PinCoordinator {

    func transition(to transition: Transition) throws {

        if let transition = transition as? PinTransition {
            switch transition {
                case .enroll(let delegate, let data):

                    var viewModel: PinViewModelType = Resolver.resolve(PinViewModelType.self)
                    viewModel.data = data

                    let controller = AppStoryboard.viewController(class: PinEnrollViewController.self)
                    controller.modalPresentationStyle = .overFullScreen
                    controller.coordinator = self
                    controller.delegate = delegate

                    self.navigationController?.present(controller, animated: true)

                case .validate(let delegate):

                    // TOOD: Error if biometrics is locked
                    if self.secureStorageServiceType.dataStoredWithBiometry && !self.secureStorageServiceType.isBiometricsLocked { Task {
                        do {
                            let data = try await self.secureStorageServiceType.getData()
                            delegate.didAuthenticate(data: data)
                        } catch {
                            delegate.didFail(with: error)
                        }
                    }} else {
                        
                        let controller = AppStoryboard.viewController(class: PinValidationViewController.self)
                        controller.modalPresentationStyle = .overFullScreen
                        controller.coordinator = self
                        controller.delegate = delegate

                        self.navigationController?.present(controller, animated: true)
                    }

                case .changePin(let delegate):

                    let controller = AppStoryboard.viewController(class: PinChangeViewController.self)
                    controller.modalPresentationStyle = .overFullScreen
                    controller.coordinator = self
                    controller.delegate = delegate

                    self.navigationController?.present(controller, animated: true)
            }
        } else {
            try self.parent?.transition(to: transition)
        }
    }

}

protocol PinDelegate: NSObjectProtocol {

    func didEnroll(data: Data)
    func didFail(with error: Error)
    func didAuthenticate(data: Data)
    func didChangePin()
    func didCancel()

}

extension PinDelegate {

    func didEnroll() {}

    func didFail(with error: Error) { }

    func didAuthenticate(data: Data) {}

    func didChangePin() {}

    func didCancel() {}
}

