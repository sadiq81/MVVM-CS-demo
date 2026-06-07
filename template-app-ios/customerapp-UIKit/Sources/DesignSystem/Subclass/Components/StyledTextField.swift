
import UIKit
import MustacheUIKit

@IBDesignable
class StyledTextField: UITextField {
    
    public override func awakeFromNib() {
        super.awakeFromNib()
        MainActor.assumeIsolated { self.configureTextStyle() }
    }

    public override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        MainActor.assumeIsolated { self.configureTextStyle() }
    }
    
    func configureTextStyle() {
        let textStyle = self.font?.fontDescriptor.object(forKey: .textStyle) as? UIFont.TextStyle ?? .body
        self.font = UIFont.preferredFont(forTextStyle: textStyle)
    }
    
}


