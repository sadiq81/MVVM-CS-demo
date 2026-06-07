
import SwiftUI

import MustacheServices

struct MoreView: View {

    @EnvironmentObject
    private var coordinator: HostingCoordinator
    
    @InjectedObject(\.moreViewModel)
    private var viewModel

    var body: some View {
        List {
            // MARK: Settings Section
            Section {
                Button {
                    try? self.coordinator.transition(to: MoreTransition.profile)
                } label: {
                    HStack {
                        Text(Strings.More.Label.profile)
                            .foregroundColor(Color(Colors.Foreground.default.color))
                        Spacer()
                        Image(systemName: Images.System.forward)
                            .foregroundColor(Color(Colors.Foreground.muted.color))
                    }
                }

                if self.viewModel.featureFlags.contains(.feature2) {
                    Button {
                        guard let url = URL(string: "https://www.claude.ai") else { return }
                        try? self.coordinator.transition(to: MoreTransition.webview(url: url))
                    } label: {
                        HStack {
                            Text(Strings.More.Label.feature2)
                                .foregroundColor(Color(Colors.Foreground.default.color))
                            Spacer()
                            Image(systemName: Images.System.forward)
                                .foregroundColor(Color(Colors.Foreground.muted.color))
                        }
                    }
                }
            } header: {
                Text(Strings.More.Caption.settings.uppercased())
                    .font(.caption)
                    .foregroundColor(Color(Colors.Foreground.muted.color))
            }

            // MARK: FaceID Section
            Section {
                Button {
                    try? self.coordinator.transition(to: MoreTransition.secureContent)
                } label: {
                    HStack {
                        Text(Strings.More.Label.secret)
                            .foregroundColor(Color(Colors.Foreground.default.color))
                        Spacer()
                        Image(systemName: Images.System.forward)
                            .foregroundColor(Color(Colors.Foreground.muted.color))
                    }
                }
            } header: {
                Text(Strings.More.Caption.faceId.uppercased())
                    .font(.caption)
                    .foregroundColor(Color(Colors.Foreground.muted.color))
            }

            // MARK: Logout Section
            Section {
                Button {
                    self.viewModel.showLogoutAlert = true
                } label: {
                    Text(Strings.More.Button.logout)
                        .font(.body)
                        .foregroundColor(Color(Colors.Foreground.danger.color))
                        .frame(maxWidth: .infinity)
                        .frame(height: 34)
                }
            }
        }
        .listStyle(.insetGrouped)
        .background(Color(Colors.Background.default.color).ignoresSafeArea())
        .scrollContentBackground(.hidden)
        .navigationTitle(Strings.Tabbar.more)
        .alert(Strings.Alert.LogOut.title, isPresented: self.$viewModel.showLogoutAlert) {
            Button(Strings.Alert.LogOut.cancel, role: .cancel) {}
            Button(Strings.Alert.LogOut.accept, role: .destructive) {
                self.viewModel.logOut()
                try? self.coordinator.transition(to: AppTransition.login)
            }
        } message: {
            Text(Strings.Alert.LogOut.message)
        }
    }
}

#if DEBUG
#Preview("MoreView") {
    Container.shared.userService.register { PreviewUserService() }
    Container.shared.loginService.register { PreviewLoginService() }
    return NavigationStack {
        MoreView()
    }
    .environmentObject(HostingCoordinator(coordinator: PreviewCoordinator()))
}
#endif
