import UIKit

extension UIView {

    /// Card style levels for visual hierarchy
    enum CardStyle {
        case elevated       // Default card with shadow and border
        case flat          // Flat card with border only
        case subtle        // Subtle background with no border
        case surfacePress  // Pressed/interactive surface
    }

    /// Apply card styling with proper elevation, borders, and background
    /// - Parameters:
    ///   - style: The card style to apply (default: .elevated)
    ///   - cornerRadius: Corner radius (default: Constants.Rounding.medium)
    ///   - padding: Internal padding (optional, for content insets)
    func styleAsCard(style: CardStyle = .elevated, cornerRadius: CGFloat = Constants.Rounding.medium, padding: UIEdgeInsets? = nil) {
        // Set corner radius
        self.layer.cornerRadius = cornerRadius
        self.layer.masksToBounds = false

        // Apply style-specific properties
        switch style {
            case .elevated:
                self.backgroundColor = Colors.Background.surface.color
                self.layer.borderWidth = 1
                self.layer.borderColor = Colors.Border.default.color.cgColor

                // Add subtle shadow for elevation
                self.layer.shadowColor = UIColor.black.cgColor
                self.layer.shadowOffset = CGSize(width: 0, height: 4)
                self.layer.shadowRadius = 8
                self.layer.shadowOpacity = 0.18

            case .flat:
                self.backgroundColor = Colors.Background.surface.color
                self.layer.borderWidth = 1
                self.layer.borderColor = Colors.Border.default.color.cgColor
                self.layer.shadowOpacity = 0

            case .subtle:
                self.backgroundColor = Colors.Background.neutralSubtle.color
                self.layer.borderWidth = 0
                self.layer.shadowOpacity = 0

            case .surfacePress:
                self.backgroundColor = Colors.Background.surfacePress.color
                self.layer.borderWidth = 1
                self.layer.borderColor = Colors.Border.default.color.cgColor
                self.layer.shadowOpacity = 0
        }

        // Apply padding if specified
        if let padding = padding {
            self.layoutMargins = padding
        }
    }

    /// Add a border with design system colors
    /// - Parameters:
    ///   - width: Border width (default: 1)
    ///   - color: Border color type from design system (default: .default)
    func addBorder(width: CGFloat = 1, color: Colors.Border.Types = .default) {
        self.layer.borderWidth = width
        self.layer.borderColor = color.color.cgColor
    }

    /// Remove all card styling
    func removeCardStyling() {
        self.layer.shadowOpacity = 0
        self.layer.borderWidth = 0
        self.backgroundColor = .clear
    }
}

// MARK: - Common Card Padding Presets

extension UIEdgeInsets {
    /// Small padding (8pt all around)
    static let cardPaddingSmall = UIEdgeInsets(uniform: Spacing.small)

    /// Medium padding (12pt all around)
    static let cardPaddingMedium = UIEdgeInsets(uniform: Spacing.medium)

    /// Large padding (16pt all around)
    static let cardPaddingLarge = UIEdgeInsets(uniform: Spacing.large)

    /// Extra large padding (24pt all around)
    static let cardPaddingXLarge = UIEdgeInsets(uniform: Spacing.section)

    /// Creates edge insets with the same value on all sides
    init(uniform value: CGFloat) {
        self.init(top: value, left: value, bottom: value, right: value)
    }
}
