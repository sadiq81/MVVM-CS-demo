import CoreGraphics

/// Spacing constants on a 4pt grid.
///
/// Pick the semantic name that matches your intent:
///
///     Spacing.small       //  8pt – between related elements (labels, icons)
///     Spacing.medium      // 12pt – between cards in a list
///     Spacing.large       // 16pt – screen margins, form field spacing, card padding
///     Spacing.section     // 24pt – between distinct sections
///
enum Spacing {

    /// 4pt – micro adjustments, half-gutters
    static let xSmall: CGFloat = 4

    /// 8pt – between tightly related elements
    static let small: CGFloat = 8

    /// 12pt – between cards or list rows
    static let medium: CGFloat = 12

    /// 16pt – screen margins, form fields, card padding
    static let large: CGFloat = 16

    /// 24pt – between sections
    static let section: CGFloat = 24
}
