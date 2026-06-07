import UIKit

/// A simple divider/separator view for creating visual separation between components
@IBDesignable
final class Divider: UIView {

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
        self.configure()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.configure()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.configure()
    }

    // MARK: - Configuration

    private func configure() {
        self.translatesAutoresizingMaskIntoConstraints = false

        // Apply style
        switch self.style {
            case .default:
                self.backgroundColor = Colors.Border.default.color

            case .strong:
                self.backgroundColor = Colors.Border.strong.color

            case .subtle:
                self.backgroundColor = Colors.Border.default.color.withAlphaComponent(0.5)
        }

        // Set size constraints based on orientation
        switch self.orientation {
            case .horizontal:
                self.heightAnchor.constraint(equalToConstant: self.style == .subtle ? 0.5 : 1).isActive = true

            case .vertical:
                self.widthAnchor.constraint(equalToConstant: self.style == .subtle ? 0.5 : 1).isActive = true
            }
    }

    // MARK: - Interface Builder Support

    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        MainActor.assumeIsolated { self.configure() }
    }
}

// MARK: - Divider Edge Placement

extension UIView {

    /// Edges where a divider can be placed. Combine freely: `[.top, .bottom]`
    struct DividerEdge: OptionSet {
        let rawValue: Int

        static let top    = DividerEdge(rawValue: 1 << 0)
        static let bottom = DividerEdge(rawValue: 1 << 1)
        static let left   = DividerEdge(rawValue: 1 << 2)
        static let right  = DividerEdge(rawValue: 1 << 3)

        static let horizontal: DividerEdge = [.top, .bottom]
        static let vertical: DividerEdge   = [.left, .right]
        static let all: DividerEdge        = [.top, .bottom, .left, .right]
    }

    /// Add dividers to one or more edges of this view.
    ///
    ///     view.addDivider(on: .bottom)
    ///     view.addDivider(on: [.top, .bottom], style: .subtle, inset: Spacing.large)
    ///
    /// - Parameters:
    ///   - edges: The edges to place dividers on.
    ///   - style: The divider style (default: `.default`).
    ///   - inset: Inset from the perpendicular edges (default: 0).
    /// - Returns: The created divider views.
    @discardableResult
    func addDivider(on edges: DividerEdge, style: Divider.Style = .default, inset: CGFloat = 0) -> [Divider] {
        var dividers: [Divider] = []

        if edges.contains(.top) {
            let divider = Divider(style: style, orientation: .horizontal)
            self.addSubview(divider)
            NSLayoutConstraint.activate([
                divider.topAnchor.constraint(equalTo: self.topAnchor),
                divider.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: inset),
                divider.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -inset)
            ])
            dividers.append(divider)
        }

        if edges.contains(.bottom) {
            let divider = Divider(style: style, orientation: .horizontal)
            self.addSubview(divider)
            NSLayoutConstraint.activate([
                divider.bottomAnchor.constraint(equalTo: self.bottomAnchor),
                divider.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: inset),
                divider.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -inset)
            ])
            dividers.append(divider)
        }

        if edges.contains(.left) {
            let divider = Divider(style: style, orientation: .vertical)
            self.addSubview(divider)
            NSLayoutConstraint.activate([
                divider.leadingAnchor.constraint(equalTo: self.leadingAnchor),
                divider.topAnchor.constraint(equalTo: self.topAnchor, constant: inset),
                divider.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -inset)
            ])
            dividers.append(divider)
        }

        if edges.contains(.right) {
            let divider = Divider(style: style, orientation: .vertical)
            self.addSubview(divider)
            NSLayoutConstraint.activate([
                divider.trailingAnchor.constraint(equalTo: self.trailingAnchor),
                divider.topAnchor.constraint(equalTo: self.topAnchor, constant: inset),
                divider.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -inset)
            ])
            dividers.append(divider)
        }

        return dividers
    }
}
