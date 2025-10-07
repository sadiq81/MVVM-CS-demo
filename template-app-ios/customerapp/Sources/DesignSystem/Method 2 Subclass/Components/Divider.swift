import UIKit

/// A simple divider/separator view for creating visual separation between components
@IBDesignable
class Divider: UIView {

    /// Divider style options
    enum Style {
        case `default`  // Standard divider (Border.default color, 1pt)
        case strong     // Strong divider (Border.strong color, 1pt)
        case subtle     // Subtle divider (lighter, 0.5pt)
    }

    /// Divider orientation
    enum Orientation {
        case horizontal
        case vertical
    }

    // MARK: - Properties

    private var style: Style = .default
    private var orientation: Orientation = .horizontal

    // MARK: - Initialization

    convenience init(style: Style = .default, orientation: Orientation = .horizontal) {
        self.init(frame: .zero)
        self.style = style
        self.orientation = orientation
        configure()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configure()
    }

    // MARK: - Configuration

    private func configure() {
        translatesAutoresizingMaskIntoConstraints = false

        // Apply style
        switch style {
        case .default:
            backgroundColor = Colors.Border.default.color

        case .strong:
            backgroundColor = Colors.Border.strong.color

        case .subtle:
            backgroundColor = Colors.Border.default.color.withAlphaComponent(0.5)
        }

        // Set size constraints based on orientation
        switch orientation {
        case .horizontal:
            heightAnchor.constraint(equalToConstant: style == .subtle ? 0.5 : 1).isActive = true

        case .vertical:
            widthAnchor.constraint(equalToConstant: style == .subtle ? 0.5 : 1).isActive = true
        }
    }

    // MARK: - Interface Builder Support

    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        configure()
    }
}

// MARK: - UIView Extension for Quick Divider Creation

extension UIView {

    /// Add a horizontal divider at the bottom of this view
    /// - Parameters:
    ///   - style: The divider style (default: .default)
    ///   - insets: Horizontal insets for the divider (default: 0)
    /// - Returns: The created divider view for further customization
    @discardableResult
    func addBottomDivider(style: Divider.Style = .default, insets: CGFloat = 0) -> Divider {
        let divider = Divider(style: style, orientation: .horizontal)
        addSubview(divider)

        NSLayoutConstraint.activate([
            divider.leadingAnchor.constraint(equalTo: leadingAnchor, constant: insets),
            divider.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -insets),
            divider.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])

        return divider
    }

    /// Add a horizontal divider at the top of this view
    /// - Parameters:
    ///   - style: The divider style (default: .default)
    ///   - insets: Horizontal insets for the divider (default: 0)
    /// - Returns: The created divider view for further customization
    @discardableResult
    func addTopDivider(style: Divider.Style = .default, insets: CGFloat = 0) -> Divider {
        let divider = Divider(style: style, orientation: .horizontal)
        addSubview(divider)

        NSLayoutConstraint.activate([
            divider.leadingAnchor.constraint(equalTo: leadingAnchor, constant: insets),
            divider.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -insets),
            divider.topAnchor.constraint(equalTo: topAnchor)
        ])

        return divider
    }
}
