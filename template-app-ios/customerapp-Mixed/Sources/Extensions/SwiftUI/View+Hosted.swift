import SwiftUI

import MustacheServices

extension View {

    /// Wraps this SwiftUI view in a `UIHostingController` with a `HostingCoordinator` environment object.
    /// Replaces the repeated two-line pattern:
    /// ```
    /// .environmentObject(HostingCoordinator(coordinator: self))
    /// let controller = UIHostingController(rootView: view)
    /// ```
    func hosted(by coordinator: some CoordinatorType) -> UIHostingController<some View> {
        let view = self.environmentObject(HostingCoordinator(coordinator: coordinator))
        let controller = UIHostingController(rootView: view)
        controller.view.backgroundColor = .clear
        return controller
    }

}
