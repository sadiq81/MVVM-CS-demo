
import UIKit
import MustacheUIKit

@IBDesignable
class StyledLabel: UILabel {
    
    @IBInspectable
    public var emphasized: Bool = false {
        didSet {
            self.configureTextStyle()
        }
    }
    
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
        if self.emphasized {
            self.font = UIFont.preferredFont(forTextStyle: textStyle.emphasized)
        } else {
            self.font = UIFont.preferredFont(forTextStyle: textStyle)
        }
        
    }
    
}
