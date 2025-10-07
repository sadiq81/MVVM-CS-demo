
import UIKit

extension UIViewController {

    @discardableResult
    func constrainKeyboard(to view: UIView) -> [NSLayoutConstraint] {
        let keyboardConstraint = view.bottomAnchor.constraint(lessThanOrEqualTo: self.view.keyboardLayoutGuide.topAnchor)
        keyboardConstraint.priority = .required // 1000
        keyboardConstraint.isActive = true
        
        // Bottom constraint: bottom should stick to view bottom (lower priority)
        let bottomConstraint = view.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
        bottomConstraint.priority = .defaultHigh // 750
        bottomConstraint.isActive = true
        
        return [keyboardConstraint, bottomConstraint]
    }
    
}
