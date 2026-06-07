
import SwiftUI

import MustacheServices

struct SecretView: View {

    @InjectedObject(\.secretViewModel)
    private var viewModel

    var body: some View {
        VStack(spacing: 20) {

            Spacer()

            // MARK: Secret Label
            Text(self.viewModel.secretText)
                .font(.subheadline)
                .foregroundColor(Color(Colors.Foreground.default.color))

            // MARK: Feature 1 Toggle
            self.featureToggleRow(
                title: "Feature 1",
                isOn: Binding(
                    get: { self.viewModel.feature1Enabled },
                    set: { self.viewModel.toggleFeature(.feature1, isOn: $0) }
                )
            )

            // MARK: Feature 2 Toggle
            self.featureToggleRow(
                title: "Feature 2",
                isOn: Binding(
                    get: { self.viewModel.feature2Enabled },
                    set: { self.viewModel.toggleFeature(.feature2, isOn: $0) }
                )
            )

            Spacer()
        }
        .overlay {
            if self.viewModel.isLoading {
                ProgressView()
                    .tint(Color(Colors.Foreground.brand.color))
            }
        }
        .background(Color(Colors.Background.default.color).ignoresSafeArea())
        .navigationTitle(Strings.More.Label.secret)
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Feature Toggle Row

    @ViewBuilder
    private func featureToggleRow(title: String, isOn: Binding<Bool>) -> some View {
        HStack(spacing: 40) {
            Text(title)
                .font(.caption)
                .foregroundColor(Color(Colors.Foreground.default.color))

            Toggle("", isOn: isOn)
                .labelsHidden()
                .tint(Color(Colors.Background.brand.color))
                .disabled(self.viewModel.isLoading)
        }
    }
}

#if DEBUG
#Preview("SecretView") {
    Container.shared.userService.register { PreviewUserService() }
    Container.shared.secretViewModel.register {
        MainActor.assumeIsolated {
            let viewModel = SecretViewModel()
            viewModel.data = Data("Secret preview content".utf8)
            return viewModel
        }
    }
    return NavigationStack {
        SecretView()
    }
}
#endif
