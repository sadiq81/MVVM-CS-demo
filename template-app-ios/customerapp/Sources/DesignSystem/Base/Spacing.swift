import Foundation
import CoreGraphics

/// Standardized spacing values for consistent layout rhythm
/// Use these values for margins, padding, and spacing between elements
struct Spacing {

    /// Spacing scale following 4pt/8pt grid system
    struct Scale {
        /// 4pt - Micro spacing (tight elements)
        static let xs: CGFloat = 4

        /// 8pt - Small spacing (related elements)
        static let sm: CGFloat = 8

        /// 12pt - Comfortable spacing
        static let md: CGFloat = 12

        /// 16pt - Default spacing (standard margin)
        static let lg: CGFloat = 16

        /// 24pt - Section spacing
        static let xl: CGFloat = 24

        /// 32pt - Large section spacing
        static let xxl: CGFloat = 32

        /// 40pt - Extra large spacing
        static let xxxl: CGFloat = 40

        /// 48pt - Major section breaks
        static let xxxxl: CGFloat = 48
    }

    /// Common spacing patterns for specific use cases
    struct Common {
        /// Standard horizontal screen margin (16pt)
        static let screenMargin: CGFloat = Scale.lg

        /// Standard spacing between cards in a list (12pt)
        static let cardSpacing: CGFloat = Scale.md

        /// Spacing between form fields (16pt)
        static let formFieldSpacing: CGFloat = Scale.lg

        /// Spacing between sections (24pt)
        static let sectionSpacing: CGFloat = Scale.xl

        /// Internal card padding (16pt)
        static let cardPadding: CGFloat = Scale.lg

        /// Spacing between related UI elements (8pt)
        static let elementSpacing: CGFloat = Scale.sm
    }

    /// Stack view spacing presets
    struct StackView {
        /// Tight spacing for closely related items (4pt)
        static let tight: CGFloat = Scale.xs

        /// Normal spacing for related items (8pt)
        static let normal: CGFloat = Scale.sm

        /// Comfortable spacing (12pt)
        static let comfortable: CGFloat = Scale.md

        /// Loose spacing for separated sections (16pt)
        static let loose: CGFloat = Scale.lg
    }
}
