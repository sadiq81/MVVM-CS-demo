
import SwiftUI

import MustacheServices

struct LoginView: View {
    
    @EnvironmentObject
    private var coordinator: HostingCoordinator
    
    @InjectedObject(\.loginViewModel)
    private var viewModel
    
    @State private var isPasswordVisible: Bool = false
    
    var body: some View {
        VStack(spacing: 8) {
            Spacer()
            
            // Title
            Text(Strings.Login.title)
                .font(.title)
                .foregroundColor(Color(Colors.Foreground.default.color))
                .frame(maxWidth: .infinity, alignment: .center)
            
            // Body
            Text(Strings.Login.body)
                .font(.body)
                .foregroundColor(Color(Colors.Foreground.muted.color))
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity, alignment: .center)
            
            // Email Container
            HStack {
                TextField(Strings.Login.Textfield.Username.placeholder, text: self.$viewModel.email)
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
            
            // Password Container
            HStack {
                if self.isPasswordVisible {
                    TextField(Strings.Login.Textfield.Password.placeholder, text: self.$viewModel.password)
                        .font(.body)
                        .textContentType(.password)
                } else {
                    SecureField(Strings.Login.Textfield.Password.placeholder, text: self.$viewModel.password)
                        .font(.body)
                        .textContentType(.password)
                }
                
                Button(action: {
                    self.isPasswordVisible.toggle()
                }) {
                    Image(systemName: self.isPasswordVisible ? "eye" : "eye.slash")
                        .foregroundColor(Color(Colors.Foreground.default.color))
                }
            }
            .padding(.horizontal, 20)
            .frame(height: 44)
            .background(Color(Colors.Background.neutralSubtle.color))
            .cornerRadius(Constants.Rounding.small)
            
            // Login Button
            Button(
                action: { Task {
                    let success = await self.viewModel.login()
                    if success {
                        try? self.coordinator.transition(to: LoginTransition.loginCompleted)
                    }
                }},
                label:{
                    Text(Strings.Login.Button.Login.title)
                        .frame(maxWidth: .infinity)
                })
            .buttonStyle(PrimaryButtonStyle(isEnabled: self.viewModel.isValid))
            .disabled(!self.viewModel.isValid)

            // Create Account Button
            Button(action: {
                try? self.coordinator.transition(to: LoginTransition.showSignup)
            }) {
                Text(Strings.Login.Button.Signup.title)
                    .font(.caption)
                    .underline()
                    .foregroundColor(Color(Colors.Component.Button.Link.Foreground.default.color))
            }
            .frame(height: 44)

            // Forgot Password Button
            Button(action: {
                try? self.coordinator.transition(to: LoginTransition.showForgotPassword)
            }) {
                Text(Strings.Login.Button.Forgot.title)
                    .font(.caption)
                    .underline()
                    .foregroundColor(Color(Colors.Component.Button.Link.Foreground.default.color))
            }
            .frame(height: 56)
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 20)
        .background(Color(Colors.Background.default.color).ignoresSafeArea())
        .navigationBarHidden(true)
        .alert(Strings.Error.Generic.title, isPresented: self.$viewModel.showError) {
            Button(Strings.Button.ok, role: .cancel) {}
        } message: {
            Text(self.viewModel.errorMessage ?? Strings.Error.Generic.message)
        }
        .onAppear {
#if DEBUG
            self.viewModel.email = "th@mustache.dk"
            self.viewModel.password = "pickle123"
#endif
        }
    }
}

#if DEBUG
#Preview("LoginView") {
    Container.shared.loginService.register { PreviewLoginService() }
    return NavigationStack {
        LoginView()
    }
    .environmentObject(HostingCoordinator(coordinator: PreviewCoordinator()))
}
#endif
