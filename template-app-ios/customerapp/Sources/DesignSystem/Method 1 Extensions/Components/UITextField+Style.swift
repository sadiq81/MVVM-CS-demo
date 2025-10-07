
import UIKit

extension UITextField {
    
    func configure(textStyle: UIFont.TextStyle, emphasized: Bool = false, placeholder: String? = nil, color: Colors.Foreground.Types = .default) {
        self.font = UIFont.preferredFont(forTextStyle: emphasized ? textStyle.emphasized : textStyle)
        self.textColor = color.color
        self.placeholder = placeholder
    }
    
}


