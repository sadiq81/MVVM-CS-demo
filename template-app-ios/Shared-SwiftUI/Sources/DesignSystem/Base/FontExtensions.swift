import SwiftUI
import UIKit

extension SwiftUI.Font {

    // MARK: - UIFont.TextStyle Bridge

    /// Creates a SwiftUI Font from a UIFont.TextStyle, respecting the app's custom font configuration
    static func textStyle(_ style: UIFont.TextStyle) -> SwiftUI.Font {
        let uiFont = UIFont.preferredFont(forTextStyle: style)
        return SwiftUI.Font.custom(uiFont.fontName, size: uiFont.pointSize)
    }

    // MARK: - Common Text Styles

    static var largeTitle: SwiftUI.Font {
        .textStyle(.largeTitle)
    }

    static var title: SwiftUI.Font {
        .textStyle(.title1)
    }

    static var title2: SwiftUI.Font {
        .textStyle(.title2)
    }

    static var title3: SwiftUI.Font {
        .textStyle(.title3)
    }

    static var headline: SwiftUI.Font {
        .textStyle(.headline)
    }

    static var subheadline: SwiftUI.Font {
        .textStyle(.subheadline)
    }

    static var body: SwiftUI.Font {
        .textStyle(.body)
    }

    static var callout: SwiftUI.Font {
        .textStyle(.callout)
    }

    static var footnote: SwiftUI.Font {
        .textStyle(.footnote)
    }

    static var caption: SwiftUI.Font {
        .textStyle(.caption1)
    }

    static var caption2: SwiftUI.Font {
        .textStyle(.caption2)
    }

    // MARK: - Emphasized Styles

    static var emphasizedLargeTitle: SwiftUI.Font {
        .textStyle(.largeTitle).bold()
    }

    static var emphasizedTitle: SwiftUI.Font {
        .textStyle(.title1).bold()
    }

    static var emphasizedTitle2: SwiftUI.Font {
        .textStyle(.title2).bold()
    }

    static var emphasizedTitle3: SwiftUI.Font {
        .textStyle(.title3).bold()
    }

    static var emphasizedHeadline: SwiftUI.Font {
        .textStyle(.headline).bold()
    }

    static var emphasizedSubheadline: SwiftUI.Font {
        .textStyle(.subheadline).bold()
    }

    static var emphasizedBody: SwiftUI.Font {
        .textStyle(.body).bold()
    }

    static var emphasizedCallout: SwiftUI.Font {
        .textStyle(.callout).bold()
    }

    static var emphasizedFootnote: SwiftUI.Font {
        .textStyle(.footnote).bold()
    }

    static var emphasizedCaption: SwiftUI.Font {
        .textStyle(.caption1).bold()
    }

    static var emphasizedCaption2: SwiftUI.Font {
        .textStyle(.caption2).bold()
    }

    // MARK: - Convenience Aliases

    /// Alias for button labels and interactive elements
    static var label: SwiftUI.Font {
        .emphasizedSubheadline
    }

    /// Alias for smaller labels
    static var labelSmall: SwiftUI.Font {
        .emphasizedFootnote
    }
}
