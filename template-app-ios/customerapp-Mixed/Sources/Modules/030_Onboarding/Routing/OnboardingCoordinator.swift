import Combine
import SwiftUI
import UIKit

import MustacheServices
import MustacheUIKit

@MainActor
final class OnboardingCoordinator: NSObject, UIKitCoordinatorType, Completion {

    var baseController: UIViewController? { self.navigationController }

    weak var navigationController: UINavigationController?
    weak var parent: (any CoordinatorType)?

    var children = NSHashTable<AnyObject>.weakObjects()

    init(parent: any CoordinatorType, navigationController: UINavigationController) {
        self.parent = parent
        self.navigationController = navigationController
        super.init()
    }

    func start() throws {
        let controller = OnboardingCoordinatorView().hosted(by: self)
        self.navigationController?.setViewControllers([controller], animated: false)
    }

    func stop() throws {}

    func route(to route: Route) {}

    func transition(to transition: MustacheServices.Transition) throws {
        if let transition = transition as? AppTransition {
            switch transition {
                case .onboardingCompleted:
                    try self.parent?.stop(with: self)
                default:
                    break
            }
        } else {
            try self.parent?.transition(to: transition)
        }
    }

    deinit {
        debugPrint("deinit \(self)")
    }
}
