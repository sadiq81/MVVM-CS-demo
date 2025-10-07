
import Foundation
import UIKit

extension UIView {

    func startFlashingBorder(toColor: UIColor = Colors.Border.default.color) {
        guard self.layer.animation(forKey: "borderColor") == nil else { return }
        self.layer.borderWidth = 1
        self.layer.borderColor =  UIColor.clear.cgColor

        let animation = CABasicAnimation(keyPath: "borderColor")
        animation.fromValue = UIColor.clear.cgColor
        animation.toValue = toColor.cgColor
        animation.duration = 0.65
        animation.autoreverses = true
        animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        animation.repeatCount = .infinity
        self.layer.add(animation, forKey: "borderColor")
    }

    func stopFlashingBorder(resetBorderColor: UIColor = .clear) {
        self.layer.removeAnimation(forKey: "borderColor")
        self.layer.borderWidth = 0
    }

}
