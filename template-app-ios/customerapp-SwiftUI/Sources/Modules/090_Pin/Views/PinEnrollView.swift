
import SwiftUI

import MustacheServices
import NavigatorUI

struct PinEnrollView: View {

    @Environment(\.navigator)
    private var navigator: Navigator

    @ObservedObject
    private var viewModel: PinViewModel

    @FocusState private var pinFocused: Bool
    @FocusState private var repeatPinFocused: Bool

    init(viewModel: PinViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        VStack(spacing: 0) {

            Spacer()
            // MARK: Panel
            VStack(spacing: 24) {

                // MARK: Close Button
                HStack {
                    Spacer()
                    Button {
                        self.viewModel.dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.title2)
                            .foregroundStyle(Color(Colors.Foreground.muted.color))
                    }
                }

                // MARK: Title
                Text(Strings.Pin.Enroll.title)
                    .font(.title)
                    .foregroundColor(Color(Colors.Foreground.default.color))
                    .frame(maxWidth: .infinity, alignment: .center)

                // MARK: Body
                Text(Strings.Pin.Enroll.body)
                    .font(.body)
                    .foregroundColor(Color(Colors.Foreground.muted.color))
                    .frame(maxWidth: .infinity, alignment: .center)

                // MARK: PIN Input
                if self.viewModel.showSuccess {
                    // Success indicator -- shown after keyboard dismisses
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 48))
                        .foregroundColor(Color(Colors.Foreground.success.color))
                        .transition(.scale.combined(with: .opacity))
                        .frame(height: 120)
                } else {
                    // Horizontal scroll between enter and confirm
                    GeometryReader { geometry in
                        ScrollViewReader { proxy in
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 0) {
                                    // Page 1: Enter PIN
                                    VStack(spacing: 16) {
                                        PinInputView(pin: self.$viewModel.pin, isFocused: self.$pinFocused)
                                    }
                                    .frame(width: geometry.size.width)
                                    .id("enter")

                                    // Page 2: Confirm PIN
                                    VStack(spacing: 16) {
                                        Text(Strings.Pin.Enroll.repeat)
                                            .font(.body)
                                            .foregroundColor(Color(Colors.Foreground.muted.color))

                                        PinInputView(pin: self.$viewModel.repeatPin, isFocused: self.$repeatPinFocused)
                                    }
                                    .frame(width: geometry.size.width)
                                    .id("confirm")
                                }
                            }
                            .scrollDisabled(true)
                            .onChange(of: self.viewModel.phase) { _, phase in
                                withAnimation(.easeInOut(duration: 0.3)) {
                                    proxy.scrollTo(phase == .confirm ? "confirm" : "enter", anchor: .leading)
                                }
                            }
                        }
                    }
                    .frame(height: 120)
                }
                Spacer()
                    .frame(height: 24)
            }
            .padding(.top, 24)
            .padding(.horizontal, 24)
            .background {
                UnevenRoundedRectangle(cornerRadii:
                        .init(topLeading: 12, topTrailing: 12))
                    .fill(Color(Colors.Background.surface.color))
                    .ignoresSafeArea(.container, edges: .bottom)
            }
        }
        .background(Color.black.opacity(0.7))
        .onAppear {
            self.pinFocused = true
        }
        .onChange(of: self.viewModel.pin) { _, newValue in
            if newValue.count == 4 && self.viewModel.phase == .enter {
                withAnimation(.easeInOut(duration: 0.3)) {
                    self.viewModel.phase = .confirm
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                    self.repeatPinFocused = true
                }
            }
        }
        .onChange(of: self.viewModel.repeatPin) { _, newValue in
            if newValue.count == 4 {
                self.pinFocused = false
                self.repeatPinFocused = false
                self.viewModel.store()
            }
            if newValue.isEmpty && !self.viewModel.pin.isEmpty && self.viewModel.phase == .confirm {
                withAnimation(.easeInOut(duration: 0.3)) {
                    self.viewModel.phase = .enter
                    self.viewModel.pin = ""
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                    self.pinFocused = true
                }
            }
        }
        .onReceive(self.viewModel.$isFinished) { isFinished in
            if isFinished {
                self.viewModel.isFinished = false
                self.navigator.back()
            }
        }
        .onReceive(self.viewModel.$completion) { completion in
            guard let completion else { return }
            self.navigator.navigate(to: MoreDestination.secureContent)
        }
        .alert(Strings.Error.Generic.title, isPresented: self.$viewModel.showError) {
            Button(Strings.Button.ok) {}
        } message: {
            Text(self.viewModel.errorMessage)
        }
        .alert(self.viewModel.biometricTitle, isPresented: self.$viewModel.showBiometricAlert) {
            Button(Strings.Button.ok) {
                self.viewModel.storeWithBiometric()
            }
            Button(Strings.Button.cancel, role: .cancel) {
                self.viewModel.declineBiometric()
            }
        } message: {
            Text(self.viewModel.biometricMessage)
        }
    }
}

#if DEBUG
#Preview("PinEnrollView") {
    let viewModel = PinViewModel(data: nil)
    return NavigationStack {
        PinEnrollView(viewModel: viewModel)
    }
}
#endif
