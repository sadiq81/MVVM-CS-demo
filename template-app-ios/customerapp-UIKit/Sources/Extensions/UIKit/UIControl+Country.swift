import ObjectiveC
import UIKit

nonisolated(unsafe) private var countryKey: UInt8 = 0

extension UIControl {

    /// The associated `Country`, stored via an associated object
    var country: Country? {
        get {
            objc_getAssociatedObject(self, &countryKey) as? Country
        }
        set {
            objc_setAssociatedObject(self, &countryKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
}
