import Combine
import SwiftUI
import UIKit

@preconcurrency import MustacheServices
import MustacheUIKit

// MARK: - Mixed Pin Coordinator

@MainActor
final class PinCoordinator: NSObject, UIKitCoordinatorType {

    // MARK: - Properties

    var baseController: UIViewController? { return self.navigationController }

    weak var navigationController: UINavigationController?

    weak var delegate: PinDelegate?
    weak var parent: (any CoordinatorType)?

    // MARK: - Services

    @Injected(\.secureStorageService)
    private var secureStorageService: any SecureStorageServiceType

    // MARK: - Init

    init(parent: any CoordinatorType, navigationController: UINavigationController?) {
        self.parent = parent
        self.navigationController = navigationController
        super.init()
    }

    func start() throws {}

    func stop(with completion: (any Completion)?) throws {
        if let completion = completion as? PinCompletion {
            switch completion {
                case .enrolled(let data):
                    self.navigationController?.dismiss(animated: true) { [weak self] in
                        self?.delegate?.didEnroll(data: data)
                    }
                case .validated(let data):
                    self.navigationController?.dismiss(animated: true) { [weak self] in
                        self?.delegate?.didAuthenticate(data: data)
                    }
                case .changePin:
                    self.navigationController?.dismiss(animated: true) { [weak self] in
                        self?.delegate?.didChangePin()
                    }
            }
        } else {
            try? self.parent?.stop(with: completion)
        }
    }

    // MARK: - Transitions

    func transition(to transition: MustacheServices.Transition) throws {
        if let transition = transition as? PinTransition {

            switch transition {
                case .enroll(let delegate, let data):
                    self.delegate = delegate
                    
                    let viewModel = Container.shared.pinViewModel(data)
                    
                    let controller = PinEnrollView(viewModel: viewModel).hosted(by: self)
                    controller.modalPresentationStyle = .overFullScreen
                    
                    self.navigationController?.present(controller, animated: true)

                case .validate(let delegate):
                    self.delegate = delegate
                    
                    let viewModel = Container.shared.pinViewModel(nil)

                    // Try biometrics first
                    if self.secureStorageService.dataStoredWithBiometry && !self.secureStorageService.isBiometricsLocked {
                        Task {
                            do {
                                let data = try await self.secureStorageService.getData()
                                delegate.didAuthenticate(data: data)
                            } catch {
                                let controller = PinValidationView(viewModel: viewModel).hosted(by: self)
                                controller.modalPresentationStyle = .overFullScreen
                                self.navigationController?.present(controller, animated: true)
                            }
                        }
                    } else {
                        let controller = PinValidationView(viewModel: viewModel).hosted(by: self)
                        controller.modalPresentationStyle = .overFullScreen
                        self.navigationController?.present(controller, animated: true)
                    }

                case .changePin(let delegate):
                    self.delegate = delegate
                    
                    // This method should only be call from a context where
                    // the data has already been unlocked and can be given to the viewmodel
                    
                    let viewModel = Container.shared.pinViewModel(nil)
                    let controller = PinChangeView(viewModel: viewModel).hosted(by: self)
                    controller.modalPresentationStyle = .overFullScreen
                    self.navigationController?.present(controller, animated: true)
            }
        } else {
            try self.parent?.transition(to: transition)
        }
    }

    func route(to route: any MustacheServices.Route) {}

    deinit {
        debugPrint("deinit \(self)")
    }
}
