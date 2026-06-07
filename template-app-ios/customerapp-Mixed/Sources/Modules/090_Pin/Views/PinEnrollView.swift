
import SwiftUI

import MustacheServices

struct PinEnrollView: View {

    @EnvironmentObject
    private var coordinator: HostingCoordinator
    
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
                        try? self.coordinator.transition(to: MoreTransition.dismiss)
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
                    // Success indicator — shown after keyboard dismisses
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
            // Auto-submit when repeat PIN is 4 digits
            if newValue.count == 4 {
                Task { await self.viewModel.store() }
            }
            // Go back to first PIN if user deletes all in repeat
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
        .alert(Strings.Error.Generic.title, isPresented: self.$viewModel.showError) {
            Button(Strings.Button.ok) {}
        } message: {
            Text(self.viewModel.errorMessage)
        }
        .alert(self.viewModel.biometricTitle, isPresented: self.$viewModel.showBiometricAlert) {
            Button(Strings.Button.ok) {
                Task {
                    await self.viewModel.storeWithBiometric()
                    self.completeEnroll()
                }
            }
            Button(Strings.Button.cancel, role: .cancel) {
                self.completeEnroll()
            }
        } message: {
            Text(self.viewModel.biometricMessage)
        }
    }

    private func completeEnroll() {
        // Dismiss keyboard first so checkmark is visible
        self.pinFocused = false
        self.repeatPinFocused = false

        withAnimation {
            self.viewModel.showSuccess = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            if let data = self.viewModel.data {
                try? self.coordinator.stop(with: PinCompletion.enrolled(data))
            }
        }
    }
}

#if DEBUG
#Preview("PinEnrollView") {
    let viewModel = PinViewModel(data: nil)
    return NavigationStack {
        PinEnrollView(viewModel: viewModel)
            .environmentObject(HostingCoordinator(coordinator: PreviewCoordinator()))
    }
}
#endif
