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
    func styleAsCard(
        style: CardStyle = .elevated,
        cornerRadius: CGFloat = Constants.Rounding.medium,
        padding: UIEdgeInsets? = nil
    ) {
        // Set corner radius
        layer.cornerRadius = cornerRadius
        layer.masksToBounds = false

        // Apply style-specific properties
        switch style {
        case .elevated:
            backgroundColor = Colors.Background.surface.color
            layer.borderWidth = 1
            layer.borderColor = Colors.Border.default.color.cgColor

            // Add subtle shadow for elevation
            layer.shadowColor = UIColor.black.cgColor
            layer.shadowOffset = CGSize(width: 0, height: 2)
            layer.shadowRadius = 4
            layer.shadowOpacity = 0.08

        case .flat:
            backgroundColor = Colors.Background.surface.color
            layer.borderWidth = 1
            layer.borderColor = Colors.Border.default.color.cgColor
            layer.shadowOpacity = 0

        case .subtle:
            backgroundColor = Colors.Background.neutralSubtle.color
            layer.borderWidth = 0
            layer.shadowOpacity = 0

        case .surfacePress:
            backgroundColor = Colors.Background.surfacePress.color
            layer.borderWidth = 1
            layer.borderColor = Colors.Border.default.color.cgColor
            layer.shadowOpacity = 0
        }

        // Apply padding if specified
        if let padding = padding {
            layoutMargins = padding
        }
    }

    /// Add a border with design system colors
    /// - Parameters:
    ///   - width: Border width (default: 1)
    ///   - color: Border color type from design system (default: .default)
    func addBorder(width: CGFloat = 1, color: Colors.Border.Types = .default) {
        layer.borderWidth = width
        layer.borderColor = color.color.cgColor
    }

    /// Remove all card styling
    func removeCardStyling() {
        layer.shadowOpacity = 0
        layer.borderWidth = 0
        backgroundColor = .clear
    }
}

// MARK: - Common Card Padding Presets

extension UIEdgeInsets {
    /// Small padding (8pt all around)
    static let cardPaddingSmall = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)

    /// Medium padding (12pt all around)
    static let cardPaddingMedium = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)

    /// Large padding (16pt all around)
    static let cardPaddingLarge = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)

    /// Extra large padding (24pt all around)
    static let cardPaddingXLarge = UIEdgeInsets(top: 24, left: 24, bottom: 24, right: 24)
}
