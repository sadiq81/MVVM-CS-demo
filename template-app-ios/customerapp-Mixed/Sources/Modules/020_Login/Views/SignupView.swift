
import SwiftUI

import MustacheServices

struct SignupView: View {

    @EnvironmentObject
    private var coordinator: HostingCoordinator

    @InjectedObject(\.signupViewModel)
    private var viewModel

    @State private var isPasswordVisible: Bool = false

    var body: some View {
        VStack(spacing: 8) {
            Spacer()

            // Title
            Text(Strings.Signup.title)
                .font(.title)
                .foregroundColor(Color(Colors.Foreground.default.color))
                .frame(maxWidth: .infinity, alignment: .center)

            // Body
            Text(Strings.Signup.body)
                .font(.body)
                .foregroundColor(Color(Colors.Foreground.muted.color))
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity, alignment: .center)

            // Full Name
            self.field(Strings.Signup.Textfield.Fullname.placeholder, text: self.$viewModel.fullName)
                .textContentType(.name)

            // Email
            self.field(Strings.Signup.Textfield.Email.placeholder, text: self.$viewModel.email)
                .textContentType(.emailAddress)
                .keyboardType(.emailAddress)
                .autocapitalization(.none)

            // Password
            self.secureField(Strings.Signup.Textfield.Password.placeholder, text: self.$viewModel.password)

            // Confirm Password
            self.secureField(Strings.Signup.Textfield.Confirmpassword.placeholder, text: self.$viewModel.confirmPassword)

            // Signup Button
            Button(action: { Task {
                let success = await self.viewModel.signup()
                if success {
                    try? self.coordinator.transition(to: LoginTransition.loginCompleted)
                }
            }}) {
                if self.viewModel.isLoading {
                    ProgressView()
                        .tint(.white)
                        .frame(maxWidth: .infinity)
                } else {
                    Text(Strings.Signup.Button.Signup.title)
                        .frame(maxWidth: .infinity)
                }
            }
            .buttonStyle(PrimaryButtonStyle(isEnabled: self.viewModel.isValid))
            .disabled(!self.viewModel.isValid || self.viewModel.isLoading)
            .padding(.top, 8)
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 20)
        .background(Color(Colors.Background.default.color).ignoresSafeArea())
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    try? self.coordinator.transition(to: LoginTransition.dismissSignup)
                }) {
                    HStack(spacing: 4) {
                        Image(systemName: Images.System.back)
                        Text(Strings.Button.back)
                    }
                    .foregroundColor(Color(Colors.Foreground.brand.color))
                }
            }
        }
        .alert(Strings.Error.Generic.title, isPresented: self.$viewModel.showError) {
            Button(Strings.Button.ok, role: .cancel) {}
        } message: {
            Text(self.viewModel.errorMessage ?? Strings.Error.Generic.message)
        }
    }

    // MARK: - Helpers

    @ViewBuilder
    private func field(_ placeholder: String, text: Binding<String>) -> some View {
        HStack {
            TextField(placeholder, text: text)
                .font(.body)

            if !text.wrappedValue.isEmpty {
                Button(action: { text.wrappedValue = "" }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(Color(Colors.Foreground.muted.color))
                }
            }
        }
        .padding(.horizontal, 20)
        .frame(height: 44)
        .background(Color(Colors.Background.neutralSubtle.color))
        .cornerRadius(Constants.Rounding.small)
    }

    @ViewBuilder
    private func secureField(_ placeholder: String, text: Binding<String>) -> some View {
        HStack {
            if self.isPasswordVisible {
                TextField(placeholder, text: text)
                    .font(.body)
                    .textContentType(.password)
            } else {
                SecureField(placeholder, text: text)
                    .font(.body)
                    .textContentType(.password)
            }
        }
        .padding(.horizontal, 20)
        .frame(height: 44)
        .background(Color(Colors.Background.neutralSubtle.color))
        .cornerRadius(Constants.Rounding.small)
    }
}

#if DEBUG
#Preview("SignupView") {
    Container.shared.loginService.register { PreviewLoginService() }
    return NavigationStack {
        SignupView()
    }
    .environmentObject(HostingCoordinator(coordinator: PreviewCoordinator()))
}
#endif
