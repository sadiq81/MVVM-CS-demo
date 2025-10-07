
import UIKit

extension UIImageView {

    /// Configure the image view as a PIN loading indicator with SF Symbol
    func configurePinLoadingIndicator() {
        self.image = UIImage(systemName: "arrow.trianglehead.clockwise.rotate.90")
        self.preferredSymbolConfiguration = UIImage.SymbolConfiguration(pointSize: 48, weight: .regular)
        self.tintColor = Colors.Foreground.default.color
    }

    /// Show success checkmark animation and wait briefly
    func showPinSuccessAnimation() async throws {
        self.removeAllSymbolEffects()
        self.setSymbolImage(UIImage(systemName: "checkmark.circle.fill")!, contentTransition: .replace.offUp)
        self.addSymbolEffect(.bounce, options: .default, animated: true)

        // Wait briefly to show success animation
        try await Task.sleep(for: .milliseconds(500))
    }

    /// Reset the loading indicator to initial state
    func resetPinLoadingIndicator() {
        self.removeAllSymbolEffects()
        self.image = UIImage(systemName: "arrow.trianglehead.clockwise.rotate.90")
    }

    /// Start the rotating loading animation
    func startPinLoadingAnimation() {
        if #available(iOS 18.0, *) {
            self.addSymbolEffect(.rotate, options: .repeat(.continuous), animated: true)
        }
    }
}
