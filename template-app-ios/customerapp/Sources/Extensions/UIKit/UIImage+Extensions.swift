
import Foundation
import UIKit

extension UIImage {

    func with(alpha: CGFloat) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(self.size, false, self.scale)
        self.draw(at: .zero, blendMode: .normal, alpha: alpha)
        let alphaImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return alphaImage
    }

}
