#if DEBUG
import Combine
import UIKit

import MustacheServices

final class UIKitPreviewCoordinator: NSObject, CoordinatorType {

    weak var parent: (any CoordinatorType)?
    weak var navigationController: UINavigationController?

    var baseController: UIViewController? { self.navigationController }
    var childCoordinators = NSHashTable<AnyObject>.weakObjects()

    func start() throws {}

    func stop() throws {}

    func transition(to transition: Transition) throws {}

    func route(to route: Route) {}

}
#endif
