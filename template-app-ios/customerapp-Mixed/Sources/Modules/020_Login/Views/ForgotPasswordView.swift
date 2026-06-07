
import SwiftUI

import MustacheServices

struct ForgotPasswordView: View {

    @EnvironmentObject
    private var coordinator: HostingCoordinator

    @StateObject private var viewModel: ForgotPasswordViewModel

    init(viewModel: ForgotPasswordViewModel = ForgotPasswordViewModel()) {
        self._viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        VStack(spacing: 8) {
            Spacer()

            // Title
            Text(Strings.ForgotPassword.title)
                .font(.title)
                .foregroundColor(Color(Colors.Foreground.default.color))
                .frame(maxWidth: .infinity, alignment: .center)

            // Body
            Text(Strings.ForgotPassword.body)
                .font(.body)
                .foregroundColor(Color(Colors.Foreground.muted.color))
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity, alignment: .center)

            // Email Container
            HStack {
                TextField(Strings.ForgotPassword.Textfield.placeholder, text: self.$viewModel.email)
                    .font(.body)
                    .textContentType(.emailAddress)
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)

                if !self.viewModel.email.isEmpty {
                    Button(action: { self.viewModel.email = "" }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(Color(Colors.Foreground.muted.color))
                    }
                }
            }
            .padding(.horizontal, 20)
            .frame(height: 44)
            .background(Color(Colors.Background.neutralSubtle.color))
            .cornerRadius(Constants.Rounding.small)

            // Reset Button
            Button(action: {
                self.viewModel.resetPassword()
            }) {
                if self.viewModel.isLoading {
                    ProgressView()
                        .tint(.white)
                        .frame(maxWidth: .infinity)
                } else {
                    Text(Strings.ForgotPassword.Button.title)
                        .frame(maxWidth: .infinity)
                }
            }
            .buttonStyle(PrimaryButtonStyle(isEnabled: self.viewModel.isValid))
            .disabled(!self.viewModel.isValid || self.viewModel.isLoading)
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 20)
        .background(Color(Colors.Background.default.color).ignoresSafeArea())
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    try? self.coordinator.transition(to: LoginTransition.dismissForgotPassword)
                }) {
                    HStack(spacing: 4) {
                        Image(systemName: Images.System.back)
                        Text(Strings.Button.back)
                    }
                    .foregroundColor(Color(Colors.Foreground.brand.color))
                }
            }
        }
        .alert(Strings.Alert.PasswordReset.title, isPresented: self.$viewModel.showSuccess) {
            Button(Strings.Button.ok) {
                try? self.coordinator.transition(to: LoginTransition.dismissForgotPassword)
            }
        } message: {
            Text(Strings.Alert.PasswordReset.message)
        }
        .alert(Strings.Error.Generic.title, isPresented: self.$viewModel.showError) {
            Button(Strings.Button.ok) {}
        } message: {
            Text(self.viewModel.errorMessage)
        }
    }
}

#if DEBUG
#Preview("ForgotPasswordView") {
    let viewModel = ForgotPasswordViewModel()
    viewModel.email = "th@mustache.dk"
    return NavigationStack {
        ForgotPasswordView(viewModel: viewModel)
    }
    .environmentObject(HostingCoordinator(coordinator: PreviewCoordinator()))
}
#endif
