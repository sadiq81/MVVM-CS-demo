import Combine
import UIKit

import MustacheFoundation
import MustacheServices
import MustacheUIKit

@MainActor
final class PinCoordinator: NSObject, UIKitCoordinatorType {
   
    var baseController: UIViewController? { return self.navigationController }

    weak var navigationController: UINavigationController?
    weak var parent: (any CoordinatorType)?
    
    @Injected(\.secureStorageService)
    private var secureStorageServiceType: any SecureStorageServiceType

    @Injected(\.loggingService)
    private var loggingService: any LoggingServiceType

    init(parent: any CoordinatorType, navigationController: UINavigationController?) {
        self.parent = parent
        self.navigationController = navigationController
        super.init()
    }

    func start() throws { }
    
    func route(to route: any MustacheServices.Route) { }    

    deinit {
        debugPrint("deinit \(self)")
    }

}

@MainActor
extension PinCoordinator {

    func transition(to transition: MustacheServices.Transition) throws {

        if let transition = transition as? PinTransition {
            switch transition {
                case .enroll(let delegate, let data):

                    var viewModel: any PinViewModelType = Container.shared.pinViewModelType()
                    viewModel.data = data

                    let controller = AppStoryboard.viewController(class: PinEnrollViewController.self)
                    controller.modalPresentationStyle = .overFullScreen
                    controller.coordinator = self
                    controller.delegate = delegate

                    self.navigationController?.present(controller, animated: true)

                case .validate(let delegate):

                    // TOOD: Error if biometrics is locked
                        
                        Task { @MainActor in
                            let service = Container.shared.secureStorageService()
                            
                            if service.dataStoredWithBiometry && !service.isBiometricsLocked {
                                
                                do {
                                    let data = try await service.getData()
                                    delegate.didAuthenticate(data: data)
                                } catch {
                                    delegate.didFail(with: error)
                                }
                                
                            } else {
                                
                                let controller = AppStoryboard.viewController(class: PinValidationViewController.self)
                                controller.modalPresentationStyle = .overFullScreen
                                controller.coordinator = self
                                controller.delegate = delegate

                                self.navigationController?.present(controller, animated: true)
                        }
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

enum PinTransition: MustacheServices.Transition {
    case enroll(PinDelegate, Data)
    case validate(PinDelegate)
    case changePin(PinDelegate)
    
}

@MainActor
protocol PinDelegate: AnyObject {
    func didEnroll(data: Data)
    func didFail(with error: Error)
    func didAuthenticate(data: Data)
    func didChangePin()
    func didCancel()
}

extension PinDelegate {
    func didEnroll(data: Data) {}
    func didFail(with error: Error) {}
    func didAuthenticate(data: Data) {}
    func didChangePin() {}
    func didCancel() {}
}
