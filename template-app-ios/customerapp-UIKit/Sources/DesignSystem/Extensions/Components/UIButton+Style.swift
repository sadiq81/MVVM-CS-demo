import UIKit

import MustacheUIKit

@IBDesignable
extension UIButton {
    
    var isBusy: Bool {
        set {
            self.isEnabled = !newValue
            self.configuration?.showsActivityIndicator = newValue
        }
        get {
            self.configuration?.showsActivityIndicator ?? false
        }
    }

    
    func configure(style: UIButton.Style, text: String?) {
        switch style {
            case .primary, .secondary, .tertiary, .danger:
                self.setTitle(text)
                self.configuration = UIButton.Configuration.filled()
                self.configuration?.background.cornerRadius = Constants.Rounding.medium
                self.configuration?.imagePadding = 8
                self.configuration?.buttonSize = .medium
                
                self.configuration?.titleTextAttributesTransformer = self.titleTextAttributesTransformer(for: style)
                self.configurationUpdateHandler = self.configurationUpdateHandler(for: style)
            
            case .link:
                self.configureLink(text: text)
        }
    }
}

extension UIButton {
    
    func titleTextAttributesTransformer(for style: Style) -> UIConfigurationTextAttributesTransformer {
        let transformer = UIConfigurationTextAttributesTransformer { [weak button = self] incoming in
            guard let button else { return incoming }
            var outgoing = incoming
            outgoing.font = UIFont.preferredFont(forTextStyle: .subheadline.emphasized)
            switch (style, button.state) {
                    
                case (.primary, .highlighted):
                    outgoing.foregroundColor = Colors.Component.Button.Primary.Foreground.press.color
                case (.primary, .disabled):
                    outgoing.foregroundColor = Colors.Component.Button.Primary.Foreground.disabled.color
                case (.primary, _):
                    outgoing.foregroundColor = Colors.Component.Button.Primary.Foreground.default.color
                    
                    
                case (.secondary, .highlighted):
                    outgoing.foregroundColor = Colors.Component.Button.Secondary.Foreground.press.color
                case (.secondary, .disabled):
                    outgoing.foregroundColor = Colors.Component.Button.Secondary.Foreground.disabled.color
                case (.secondary, _):
                    outgoing.foregroundColor = Colors.Component.Button.Secondary.Foreground.default.color
                    
                case (.tertiary, .highlighted):
                    outgoing.foregroundColor = Colors.Component.Button.Tertiary.Foreground.press.color
                case (.tertiary,  .disabled):
                    outgoing.foregroundColor = Colors.Component.Button.Tertiary.Foreground.disabled.color
                case (.tertiary, _):
                    outgoing.foregroundColor = Colors.Component.Button.Tertiary.Foreground.default.color

                case (.danger, .highlighted):
                    outgoing.foregroundColor = Colors.Foreground.light.color
                case (.danger, .disabled):
                    outgoing.foregroundColor = Colors.Foreground.light.color.withAlphaComponent(0.5)
                case (.danger, _):
                    outgoing.foregroundColor = Colors.Foreground.light.color

                default:
                    break
            }
            return outgoing
        }
        return transformer
    }
    
    func configurationUpdateHandler(for style: Style) -> UIButton.ConfigurationUpdateHandler {
        
        let handler: UIButton.ConfigurationUpdateHandler = { button in
            
            switch (style, button.state) {
                case (.primary, .highlighted):
                    button.configuration?.baseForegroundColor = Colors.Component.Button.Primary.Foreground.press.color
                    button.configuration?.background.backgroundColor = Colors.Component.Button.Primary.Background.press.color
                case (.primary, .disabled):
                    button.configuration?.baseForegroundColor = Colors.Component.Button.Primary.Foreground.disabled.color
                    button.configuration?.background.backgroundColor = Colors.Component.Button.Primary.Background.disabled.color
                case (.primary, _):
                    button.configuration?.baseForegroundColor = Colors.Component.Button.Primary.Foreground.default.color
                    button.configuration?.background.backgroundColor = Colors.Component.Button.Primary.Background.default.color
                    
                case (.secondary, .highlighted):
                    button.configuration?.baseForegroundColor = Colors.Component.Button.Secondary.Foreground.press.color
                    button.configuration?.background.backgroundColor = Colors.Component.Button.Secondary.Background.press.color
                case (.secondary, .disabled):
                    button.configuration?.baseForegroundColor = Colors.Component.Button.Secondary.Foreground.disabled.color
                    button.configuration?.background.backgroundColor = Colors.Component.Button.Secondary.Background.disabled.color
                case (.secondary, _):
                    button.configuration?.baseForegroundColor = Colors.Component.Button.Secondary.Foreground.default.color
                    button.configuration?.background.backgroundColor = Colors.Component.Button.Secondary.Background.default.color
                    
                case (.tertiary, .highlighted):
                    button.configuration?.baseForegroundColor = Colors.Component.Button.Tertiary.Foreground.press.color
                    button.configuration?.background.backgroundColor = Colors.Component.Button.Tertiary.Background.press.color
                case (.tertiary, .disabled):
                    button.configuration?.baseForegroundColor = Colors.Component.Button.Tertiary.Foreground.disabled.color
                    button.configuration?.background.backgroundColor = Colors.Component.Button.Tertiary.Background.disabled.color
                case (.tertiary, _):
                    button.configuration?.baseForegroundColor = Colors.Component.Button.Tertiary.Foreground.default.color
                    button.configuration?.background.backgroundColor = Colors.Component.Button.Tertiary.Background.default.color

                case (.danger, .highlighted):
                    button.configuration?.baseForegroundColor = Colors.Foreground.light.color
                    button.configuration?.background.backgroundColor = Colors.Background.danger.color.withAlphaComponent(0.8)
                case (.danger, .disabled):
                    button.configuration?.baseForegroundColor = Colors.Foreground.light.color.withAlphaComponent(0.5)
                    button.configuration?.background.backgroundColor = Colors.Background.danger.color.withAlphaComponent(0.4)
                case (.danger, _):
                    button.configuration?.baseForegroundColor = Colors.Foreground.light.color
                    button.configuration?.background.backgroundColor = Colors.Background.danger.color

                default:
                    break
            }

            // Elevate the primary CTA to match SwiftUI (disabled stays flat).
            // No shadowPath: UIKit derives the (rounded) shadow from the
            // configuration's rendered background.
            if style == .primary {
                button.layer.masksToBounds = false
                button.layer.shadowColor = UIColor.black.cgColor
                button.layer.shadowOffset = CGSize(width: 0, height: 4)
                button.layer.shadowRadius = 8
                button.layer.shadowOpacity = button.state == .disabled ? 0 : 0.18
            }
        }
        return handler
    }
    
    private func configureLink(text: String?) {
        
        let baseAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.preferredFont(forTextStyle: .caption1),
            .underlineStyle: NSUnderlineStyle.single.rawValue,
        ]
        
        // MARK: Normal state
        var normalAttributes: [NSAttributedString.Key: Any] = baseAttributes
        normalAttributes[.foregroundColor] = Colors.Component.Button.Link.Foreground.default.color
        normalAttributes[.underlineColor] = Colors.Component.Button.Link.Foreground.default.color
        
        let normalAttributedTitle = NSAttributedString(string: text ?? "", attributes: normalAttributes)
        self.setAttributedTitle(normalAttributedTitle, for: .normal)
            
            // MARK: Highlighted state
        var highlightedAttributes =  baseAttributes
        highlightedAttributes[.foregroundColor] = Colors.Component.Button.Link.Foreground.press.color
        highlightedAttributes[.underlineColor] = Colors.Component.Button.Link.Foreground.press.color
        
        let highlightedAttributedTitle = NSAttributedString(string: text ?? "", attributes: highlightedAttributes)
        self.setAttributedTitle(highlightedAttributedTitle, for: .highlighted)
        
            // MARK: Disabled state
        var disabledAttributes =  baseAttributes
        disabledAttributes[.foregroundColor] = Colors.Component.Button.Link.Foreground.disabled.color
        disabledAttributes[.underlineColor] = Colors.Component.Button.Link.Foreground.disabled.color
        
        let disabledAttributedTitle = NSAttributedString(string: text ?? "", attributes: disabledAttributes)
        self.setAttributedTitle(disabledAttributedTitle, for: .disabled)
    }
}
