import SwiftUI

// MARK: - Button Styles

struct PrimaryButtonStyle: ButtonStyle {

    var isEnabled: Bool = true

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.label)
            .foregroundColor(Color(isEnabled
                ? (configuration.isPressed
                    ? Colors.Component.Button.Primary.Foreground.press.color
                    : Colors.Component.Button.Primary.Foreground.default.color)
                : Colors.Component.Button.Primary.Foreground.disabled.color))
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background(Color(isEnabled
                ? (configuration.isPressed
                    ? Colors.Component.Button.Primary.Background.press.color
                    : Colors.Component.Button.Primary.Background.default.color)
                : Colors.Component.Button.Primary.Background.disabled.color))
            .cornerRadius(Constants.Rounding.medium)
            // Elevate the primary CTA (disabled buttons stay flat)
            .shadow(color: Color.black.opacity(isEnabled ? 0.18 : 0.0), radius: 8, x: 0, y: 4)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

struct SecondaryButtonStyle: ButtonStyle {

    var isEnabled: Bool = true

    func makeBody(configuration: Configuration) -> some View {
        let foregroundColor = Color(isEnabled
            ? (configuration.isPressed
                ? Colors.Component.Button.Secondary.Foreground.press.color
                : Colors.Component.Button.Secondary.Foreground.default.color)
            : Colors.Component.Button.Secondary.Foreground.disabled.color)
        let backgroundColor = Color(isEnabled
            ? (configuration.isPressed
                ? Colors.Component.Button.Secondary.Background.press.color
                : Colors.Component.Button.Secondary.Background.default.color)
            : Colors.Component.Button.Secondary.Background.disabled.color)

        return configuration.label
            .font(.label)
            .foregroundColor(foregroundColor)
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background(backgroundColor)
            .cornerRadius(Constants.Rounding.medium)
            .overlay(
                RoundedRectangle(cornerRadius: Constants.Rounding.medium)
                    .stroke(foregroundColor, lineWidth: 1)
            )
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

struct DangerButtonStyle: ButtonStyle {

    var isEnabled: Bool = true

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.label)
            .foregroundColor(Color(Colors.Foreground.light.color)
                .opacity(isEnabled ? 1.0 : 0.5))
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background(Color(Colors.Background.danger.color)
                .opacity(isEnabled
                    ? (configuration.isPressed ? 0.8 : 1.0)
                    : 0.4))
            .cornerRadius(Constants.Rounding.medium)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

// MARK: - Loading Indicator

struct LoadingIndicator: View {
    var color: Color = Color(Colors.Foreground.brand.color)

    var body: some View {
        SwiftUI.ProgressView()
            .progressViewStyle(CircularProgressViewStyle())
            .scaleEffect(1.2)
            .accentColor(color)
    }
}

// MARK: - Card Style

struct CardModifier: ViewModifier {
    var backgroundColor: Color = Color(Colors.Background.surface.color)

    func body(content: Content) -> some View {
        content
            .background(backgroundColor)
            .cornerRadius(Constants.Rounding.large)
            .shadow(color: Color.black.opacity(0.18), radius: 8, x: 0, y: 4)
    }
}

extension View {
    func cardStyle(backgroundColor: Color = Color(Colors.Background.surface.color)) -> some View {
        modifier(CardModifier(backgroundColor: backgroundColor))
    }
}
