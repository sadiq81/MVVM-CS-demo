import Foundation
import UIKit

class SeperatorView: UIView {

    @IBInspectable
    var seperatorColor: UIColor = Colors.Border.default.color

    @IBInspectable
    var horizontal: Bool = true

    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.configure()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.configure()
    }

    override var intrinsicContentSize: CGSize {
        var intrinsicContentSize = super.intrinsicContentSize
        let lineHeight = 1.0
        if self.horizontal {
            intrinsicContentSize.height = lineHeight
        } else {
            intrinsicContentSize.width = lineHeight
        }

        return intrinsicContentSize
    }

    func configure() {
        self.backgroundColor = self.seperatorColor
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        self.configure()
    }
    
    public override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        self.configure()
    }

}
