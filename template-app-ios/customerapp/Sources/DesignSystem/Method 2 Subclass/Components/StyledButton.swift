import MustacheUIKit
import UIKit

@IBDesignable
class StyledButton: UIButton {

    override var isEnabled: Bool {
        didSet {
            self.setNeedsUpdateConfiguration()
        }
    }

    public override func awakeFromNib() {
        super.awakeFromNib()
        self.configureConfiguration()
    }

    public override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        self.configureConfiguration()
    }

    func configureConfiguration() {
        self.configuration = UIButton.Configuration.filled()
        self.configuration?.background.cornerRadius = Constants.Rounding.small
        self.configuration?.imagePadding = 8
        self.configuration?.buttonSize = .medium
    }

    override var intrinsicContentSize: CGSize {
        return CGSize(width: UIView.noIntrinsicMetric, height: Constants.Height.Button.large)
    }

}

class PrimaryButton: StyledButton {

    override func configureConfiguration() {
        super.configureConfiguration()
        self.configuration?.titleTextAttributesTransformer = self.titleTextAttributesTransformer(for: .primary)
        self.configurationUpdateHandler = self.configurationUpdateHandler(for: .primary)
    }

}

class SecondaryButton: StyledButton {

    override func configureConfiguration()  {
        super.configureConfiguration()
        self.configuration?.titleTextAttributesTransformer = self.titleTextAttributesTransformer(for: .secondary)
        self.configurationUpdateHandler = self.configurationUpdateHandler(for: .secondary)
    }

}

class TertiaryButton: StyledButton {

    override func configureConfiguration() {
        super.configureConfiguration()
        self.configuration?.titleTextAttributesTransformer = self.titleTextAttributesTransformer(for: .tertiary)
        self.configurationUpdateHandler = self.configurationUpdateHandler(for: .tertiary)
    }
}


