
import SwiftUI

import MustacheServices

struct PinValidationView: View {

    @EnvironmentObject
    private var coordinator: HostingCoordinator

    @ObservedObject
    private var viewModel: PinViewModel

    @FocusState private var pinFocused: Bool

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
                Text(Strings.Pin.Validation.title)
                    .font(.title)
                    .foregroundColor(Color(Colors.Foreground.default.color))
                    .frame(maxWidth: .infinity, alignment: .center)

                // MARK: PIN Input or Success
                if self.viewModel.showSuccess {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 48))
                        .foregroundColor(Color(Colors.Foreground.success.color))
                        .transition(.scale.combined(with: .opacity))
                        .frame(height: 120)
                } else if self.viewModel.isLoading {
                    ProgressView()
                        .controlSize(.large)
                        .tint(Color(Colors.Foreground.brand.color))
                        .frame(height: 120)
                } else {
                    PinInputView(pin: self.$viewModel.pin, isFocused: self.$pinFocused)
                }

                // MARK: Forgot PIN
                Button {
                    self.pinFocused = false
                    self.viewModel.showResetAlert = true
                } label: {
                    Text(Strings.Pin.Validation.Button.forgot)
                        .underline()
                }
                .font(.footnote)
                .foregroundColor(Color(Colors.Foreground.link.color))

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
        .onReceive(NotificationCenter.default.publisher(for: .logOut)) { _ in
            try? self.coordinator.transition(to: MoreTransition.dismiss)
        }
        .onChange(of: self.viewModel.pin) { _, newValue in
            if newValue.count == 4 {
                self.submit()
            }
        }
        .alert(Strings.Error.Generic.title, isPresented: self.$viewModel.showError) {
            Button(Strings.Button.ok) {}
        } message: {
            Text(self.viewModel.errorMessage)
        }
        .alert(Strings.Alert.Pin.Reset.title, isPresented: self.$viewModel.showResetAlert) {
            Button(Strings.Button.ok, role: .destructive) {
                self.viewModel.reset()
            }
            Button(Strings.Button.cancel, role: .cancel) {}
        } message: {
            Text(Strings.Alert.Pin.Reset.message)
        }
    }

    private func submit() {
        self.pinFocused = false

        Task {
            if let data = await self.viewModel.validate() {
                try? await Task.sleep(nanoseconds: 500_000_000)
                try? self.coordinator.stop(with: PinCompletion.validated(data))
            }
        }
    }
}

#if DEBUG
#Preview("PinValidationView") {
    let viewModel = PinViewModel(data: nil)
    return NavigationStack {
        PinValidationView(viewModel: viewModel)
            .environmentObject(HostingCoordinator(coordinator: PreviewCoordinator()))
    }
}
#endif
