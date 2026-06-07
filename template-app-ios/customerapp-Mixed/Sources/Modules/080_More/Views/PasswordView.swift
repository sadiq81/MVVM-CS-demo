
import SwiftUI

import MustacheServices

struct PasswordView: View {

    @EnvironmentObject
    private var coordinator: HostingCoordinator

    @InjectedObject(\.passwordViewModel)
    private var viewModel

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {

                // MARK: Password Fields
                VStack(spacing: 0) {
                    self.secureFieldRow(
                        caption: Strings.Password.Caption.oldPassword,
                        placeholder: Strings.Password.Textfield.Placeholder.oldPassword,
                        text: self.$viewModel.oldPassword
                    )
                    Divider()
                    self.secureFieldRow(
                        caption: Strings.Password.Caption.password,
                        placeholder: Strings.Password.Textfield.Placeholder.password,
                        text: self.$viewModel.password
                    )
                    Divider()
                    self.secureFieldRow(
                        caption: Strings.Password.Caption.repeatPassword,
                        placeholder: Strings.Password.Textfield.Placeholder.repeatPassword,
                        text: self.$viewModel.repeatPassword
                    )
                }
                .background(Color(Colors.Background.neutralSubtle.color))
                .cornerRadius(Constants.Rounding.small)
                .padding(.horizontal, 16)

                // MARK: Save Button
                Button {
                    Task { await self.viewModel.save() }
                } label: {
                    if self.viewModel.isSaving {
                        ProgressView()
                            .tint(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                    } else {
                        Text(Strings.Password.Button.save)
                            .font(.emphasizedBody)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                    }
                }
                .buttonStyle(PrimaryButtonStyle())
                .disabled(!self.viewModel.isValid || self.viewModel.isSaving)
                .opacity(self.viewModel.isValid ? 1.0 : 0.0)
                .animation(.easeInOut(duration: 0.3), value: self.viewModel.isValid)
                .padding(.horizontal, 16)
                .padding(.top, 8)
            }
            .padding(.vertical, 16)
        }
        .background(Color(Colors.Background.default.color).ignoresSafeArea())
        .navigationTitle(Strings.Profile.Button.changePassword)
        .navigationBarTitleDisplayMode(.inline)
        .alert(Strings.Error.Generic.title, isPresented: self.$viewModel.showError) {
            Button(Strings.Button.ok, role: .cancel) {}
        } message: {
            Text(self.viewModel.errorMessage ?? Strings.Error.Generic.message)
        }
        .onChange(of: self.viewModel.didSave) { didSave in
            if didSave {
                try? self.coordinator.transition(to: MoreTransition.pop)
            }
        }
    }

    // MARK: - Helpers

    @ViewBuilder
    private func secureFieldRow(caption: String, placeholder: String, text: Binding<String>) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(caption)
                .font(.caption2)
                .foregroundColor(Color(Colors.Foreground.muted.color))
            SecureField(placeholder, text: text)
                .font(.body)
                .foregroundColor(Color(Colors.Foreground.default.color))
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }
}

#if DEBUG
#Preview("PasswordView") {
    Container.shared.userService.register { PreviewUserService() }
    Container.shared.passwordViewModel.register {
        MainActor.assumeIsolated {
            let viewModel = PasswordViewModel()
            viewModel.oldPassword = "oldpass123"
            viewModel.password = "newpass123"
            viewModel.repeatPassword = "newpass123"
            viewModel.isValid = true
            return viewModel
        }
    }
    return NavigationStack {
        PasswordView()
    }
    .environmentObject(HostingCoordinator(coordinator: PreviewCoordinator()))
}
#endif
