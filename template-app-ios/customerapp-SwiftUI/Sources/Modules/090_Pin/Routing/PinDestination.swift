
import SwiftUI

import MustacheServices
import NavigatorUI

// MARK: - Pin Destination

@MainActor
enum PinDestination: NavigationDestination {

    case enroll(Data)
    case validate
    case changePin

    var body: some View {
        switch self {
            case .enroll(let data):
                let viewModel = Container.shared.pinViewModel(data)
                PinEnrollView(viewModel: viewModel)
            case .validate:
                let viewModel = Container.shared.pinViewModel(nil)
                PinValidationView(viewModel: viewModel)
            case .changePin:
                let viewModel = Container.shared.pinViewModel(nil)
                PinChangeView(viewModel: viewModel)
        }
    }

    var method: NavigationMethod {
        return .cover
    }
}
