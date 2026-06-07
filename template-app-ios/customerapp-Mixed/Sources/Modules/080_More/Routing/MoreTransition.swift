
import Foundation

import MustacheServices

enum MoreTransition: MustacheServices.Transition {
    case root
    case profile
    case password
    case countryPicker(CountrySelectionMode)
    case secureContent
    case addressSearch
    case validateAge
    case removeVerification
    case webview(url: URL)
    case pop
    case dismiss
}
