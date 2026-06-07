import Foundation

// MARK: - System Images

extension Images {

    /// Centralized system image names (SF Symbols).
    /// Usage:
    /// - UIKit: `UIImage(systemName: Images.System.dashboard)`
    /// - SwiftUI: `Image(systemName: Images.System.dashboard)`
    enum System {

        // MARK: Tab Bar

        static let dashboard = "house"
        static let search = "magnifyingglass"
        static let favorites = "bookmark"
        static let more = "ellipsis"

        // MARK: Navigation

        static let close = "xmark"
        static let back = "chevron.left"
        static let forward = "chevron.right"

        // MARK: Status

        static let checkmark = "checkmark"
        static let checkmarkCircleFill = "checkmark.circle.fill"
        static let circle = "circle"

        // MARK: Content

        static let photo = "photo"
        static let heart = "heart"
        static let heartFill = "heart.fill"
        static let heartSlash = "heart.slash"

        // MARK: Product Details

        static let euroSign = "eurosign.circle"
        static let numberSign = "number.circle"
        static let percent = "percent"

        // MARK: Loading

        static let loading = "arrow.trianglehead.clockwise.rotate.90"

        // MARK: Onboarding

        static let locationBadge = "iphone.gen3.badge.location"
        static let messageBadgeFill = "message.badge.filled.fill"
        static let cameraFill = "camera.fill"
    }
}
