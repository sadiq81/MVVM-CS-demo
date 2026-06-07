import SafariServices
import UIKit
import SwiftUI
import Foundation

// MARK: - Safari View

struct SafariView: UIViewControllerRepresentable {

    let url: URL

    func makeUIViewController(context: Context) -> SFSafariViewController {
        let controller = SFSafariViewController(url: self.url)
        controller.preferredBarTintColor = Colors.Foreground.brand.color
        controller.preferredControlTintColor = Colors.Foreground.light.color
        return controller
    }

    func updateUIViewController(_ uiViewController: SFSafariViewController, context: Context) {}
}

// MARK: - URL + Identifiable

extension URL: @retroactive Identifiable {
    public var id: String { self.absoluteString }
}
