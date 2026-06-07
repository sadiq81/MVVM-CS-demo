import UIKit

extension UILabel {

    /// Configure label with text style, emphasis, text content, and color hierarchy
    /// - Parameters:
    ///   - textStyle: The UIFont.TextStyle (body, headline, title1, etc.)
    ///   - emphasized: Whether to use emphasized (bold) font weight (default: false)
    ///   - text: The text to display
    ///   - color: The foreground color type from the design system (default: .default)
    func configure(
        textStyle: UIFont.TextStyle,
        emphasized: Bool = false,
        text: String?,
        color: Colors.Foreground.Types = .default
    ) {
        self.font = UIFont.preferredFont(forTextStyle: emphasized ? textStyle.emphasized : textStyle)
        self.textColor = color.color
        self.text = text
    }

    /// Apply only the text hierarchy color without changing font or text
    /// - Parameter color: The foreground color type from the design system
    func applyTextColor(_ color: Colors.Foreground.Types) {
        self.textColor = color.color
    }

}
