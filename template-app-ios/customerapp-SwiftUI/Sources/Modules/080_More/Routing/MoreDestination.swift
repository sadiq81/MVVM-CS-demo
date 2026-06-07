
import SwiftUI

import MustacheServices
import NavigatorUI

// MARK: - More Destination

@MainActor
enum MoreDestination: NavigationDestination {

    case profile
    case password
    case secureContent
    case countryPicker(CountrySelectionMode)
    case webview(URL)
    case addressSearch
    case validateAge

    var body: some View {
        switch self {
            case .profile:
                UserProfileView()
            case .password:
                PasswordView()
            case .secureContent:
                SecretView()
            case .countryPicker(let mode):
                CountryPickerView(mode: mode)
            case .webview(let url):
                SafariView(url: url)
                    .ignoresSafeArea()
            case .addressSearch:
                AddressSearchView()
            case .validateAge:
                OIDAuthorizationView()
        }
    }

    var method: NavigationMethod {
        switch self {
            case .profile, .password, .secureContent:
                return .push
            case .countryPicker, .webview, .validateAge, .addressSearch:
                return .sheet
        }
    }
}
