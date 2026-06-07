
import SwiftUI

import MustacheServices
import NavigatorUI

struct OnboardingView: View {

    @Environment(\.navigator)
    private var navigator: Navigator

    @InjectedObject(\.onboardingViewModel)
    private var viewModel

    var body: some View {
        ZStack {
            Color(Colors.Background.default.color)
                .ignoresSafeArea()
            if self.viewModel.hasSteps {
                self.contentView
            }
        }
        .onAppear {
            self.viewModel.checkInitialState()
        }
        .onChange(of: self.viewModel.isComplete) { _, isComplete in
            if isComplete {
                self.navigator.send(AppEvent.onboardingCompleted)
            }
        }
    }

    // MARK: - Content

    private var contentView: some View {
        let steps = self.viewModel.onboardingSteps

        return VStack(spacing: 24) {
            Spacer()

            // Step Icon
            Image(systemName: steps[self.viewModel.currentStep].systemImage)
                .font(.system(size: 64))
                .foregroundColor(Color(Colors.Foreground.brand.color))

            // Step Title
            Text(steps[self.viewModel.currentStep].localizedTitle)
                .font(.emphasizedTitle)
                .foregroundColor(Color(Colors.Foreground.default.color))

            // Step Body
            Text(steps[self.viewModel.currentStep].localizedBody)
                .font(.body)
                .foregroundColor(Color(Colors.Foreground.muted.color))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)

            Spacer()

            // Page Control
            HStack(spacing: 8) {
                ForEach(0..<steps.count, id: \.self) { index in
                    Circle()
                        .fill(index == self.viewModel.currentStep ? Color(Colors.Foreground.brand.color) : Color(Colors.Foreground.muted.color))
                        .frame(width: 8, height: 8)
                }
            }

            // Next Button
            Button(action: {
                self.viewModel.next()
            }) {
                if self.viewModel.isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity)
                } else {
                    Text(Strings.Onboarding.Button.title)
                        .frame(maxWidth: .infinity)
                }
            }
            .buttonStyle(PrimaryButtonStyle())
            .disabled(self.viewModel.isLoading)
            .padding(.horizontal, 20)
            .padding(.bottom, 20)
        }
    }
}

// MARK: - OnboardingStep SwiftUI Extensions

private extension OnboardingStep {

    var localizedTitle: String {
        switch self {
            case .location: return Strings.Onboarding.Step1.title
            case .notification: return Strings.Onboarding.Step2.title
            case .camera: return Strings.Onboarding.Step3.title
        }
    }

    var localizedBody: String {
        switch self {
            case .location: return Strings.Onboarding.Step1.body
            case .notification: return Strings.Onboarding.Step2.body
            case .camera: return Strings.Onboarding.Step3.body
        }
    }

    var systemImage: String {
        switch self {
            case .location: return Images.System.locationBadge
            case .notification: return Images.System.messageBadgeFill
            case .camera: return Images.System.cameraFill
        }
    }
}

#if DEBUG
#Preview("OnboardingView") {
    Container.shared.onboardingService.register { PreviewOnboardingService() }
    Container.shared.notificationService.register { PreviewNotificationService() }
    return NavigationStack {
        OnboardingView()
    }
}
#endif
