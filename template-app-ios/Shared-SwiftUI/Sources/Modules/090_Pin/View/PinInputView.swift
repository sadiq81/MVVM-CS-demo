
import SwiftUI

// MARK: - PIN Input View

struct PinInputView: View {

    @Binding var pin: String
    @FocusState.Binding var isFocused: Bool

    private let pinLength = 4

    var body: some View {
        HStack(spacing: 16) {
            ForEach(0..<self.pinLength, id: \.self) { index in
                PinDigitView(
                    digit: self.digit(at: index),
                    isFocused: self.isFocused && index == self.pin.count,
                    isFilled: index < self.pin.count
                )
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            self.isFocused = true
        }
        .background {
            // Hidden TextField to capture keyboard input
            TextField("", text: self.$pin)
                .keyboardType(.numberPad)
                .textContentType(.oneTimeCode)
                .focused(self.$isFocused)
                .opacity(0)
                .allowsHitTesting(false)
                .onChange(of: self.pin) { _, newValue in
                    // Filter to digits only and limit to pinLength
                    let filtered = String(newValue.filter(\.isNumber).prefix(self.pinLength))
                    if filtered != newValue {
                        self.pin = filtered
                    }
                }
        }
    }

    private func digit(at index: Int) -> String? {
        guard index < self.pin.count else { return nil }
        return String(self.pin[self.pin.index(self.pin.startIndex, offsetBy: index)])
    }
}

// MARK: - Single Digit View

private struct PinDigitView: View {

    let digit: String?
    let isFocused: Bool
    let isFilled: Bool

    @State private var showDigit: Bool = false
    @State private var caretVisible: Bool = false

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 4)
                .fill(Color(Colors.Background.neutral.color))

            RoundedRectangle(cornerRadius: 4)
                .strokeBorder(
                    Color(self.isFocused ? Colors.Border.default.color : .clear),
                    lineWidth: 2
                )

            if let digit = self.digit {
                if self.showDigit {
                    Text(digit)
                        .font(.largeTitle)
                        .foregroundColor(Color(Colors.Foreground.default.color))
                } else {
                    Text("●")
                        .font(.largeTitle)
                        .foregroundColor(Color(Colors.Foreground.default.color))
                }
            }

            // Flashing caret for focused empty digit
            if self.isFocused && self.digit == nil {
                RoundedRectangle(cornerRadius: 1)
                    .fill(Color(Colors.Foreground.default.color))
                    .frame(width: 2, height: 28)
                    .opacity(self.caretVisible ? 1 : 0)
                    .animation(.easeInOut(duration: 0.5).repeatForever(autoreverses: true), value: self.caretVisible)
                    .onAppear { self.caretVisible = true }
                    .onDisappear { self.caretVisible = false }
            }
        }
        .frame(width: 58, height: 80)
        .onChange(of: self.isFocused) { _, focused in
            self.caretVisible = focused
        }
        .onChange(of: self.digit) { oldValue, newValue in
            if oldValue == nil && newValue != nil {
                self.showDigit = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                    withAnimation(.easeInOut(duration: 0.1)) {
                        self.showDigit = false
                    }
                }
            } else if newValue == nil {
                self.showDigit = false
            }
        }
    }
}

#if DEBUG
#Preview("PinInputView") {
    struct PinPreview: View {
        @State private var pin = ""
        @FocusState private var focused: Bool
        var body: some View {
            PinInputView(pin: self.$pin, isFocused: self.$focused)
                .onAppear { self.focused = true }
        }
    }
    return PinPreview()
}
#endif
