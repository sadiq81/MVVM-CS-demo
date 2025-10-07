
import UIKit
import MustacheUIKit

@IBDesignable
class StyledTextField: UITextField {
    
    public override func awakeFromNib() {
        super.awakeFromNib()
        self.configureTextStyle()
    }
    
    public override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        self.configureTextStyle()
    }
    
    func configureTextStyle() {
        let textStyle = self.font?.fontDescriptor.object(forKey: .textStyle) as? UIFont.TextStyle ?? .body
        self.font = UIFont.preferredFont(forTextStyle: textStyle)
    }
    
}


