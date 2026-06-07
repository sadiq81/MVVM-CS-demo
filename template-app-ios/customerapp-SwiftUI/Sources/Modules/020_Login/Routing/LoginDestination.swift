
import SwiftUI

import NavigatorUI

// MARK: - Login Destination
@MainActor
enum LoginDestination: NavigationDestination {

    case forgotPassword
    case signup

    var body: some View {
        switch self {
            case .forgotPassword:
                ForgotPasswordView()
            case .signup:
                SignupView()
        }
    }

    var method: NavigationMethod { .push }
}
