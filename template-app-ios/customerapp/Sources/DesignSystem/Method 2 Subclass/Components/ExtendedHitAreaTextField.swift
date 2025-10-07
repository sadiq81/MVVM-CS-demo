
import UIKit

class ExtendedHitAreaTextField: UITextField {
    
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        guard let superview = self.superview else {
            return super.point(inside: point, with: event)
        }
        
        // Convert the touch point to the superview’s coordinate space
        let pointInSuperview = convert(point, to: superview)
        // Check if the touch is inside the superview’s bounds
        return super.point(inside: point, with: event) || superview.bounds.contains(pointInSuperview)
    }
    
}
