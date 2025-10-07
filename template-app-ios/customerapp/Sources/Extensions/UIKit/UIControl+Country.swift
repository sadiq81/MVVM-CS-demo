
import UIKit

//MARK: Giant hack, find better solution. Consider subclassing or associated object

extension UIControl {
    
    var country: Country? {
        get {
            guard let isoCountryCode = self.accessibilityIdentifier else { return nil }
            let country = Country.getCountry(from: isoCountryCode)
            return country
        } set {
            self.accessibilityIdentifier = newValue?.isoCountryCode
        }
    }
    
}
