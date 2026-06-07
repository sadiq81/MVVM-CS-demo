
import SwiftUI

import MustacheServices
import NavigatorUI

struct MoreView: View {

    @Environment(\.navigator)
    private var navigator: Navigator

    @InjectedObject(\.moreViewModel)
    private var viewModel
    
    @State private var showLogoutAlert: Bool = false

    var body: some View {
        List {
            // MARK: Settings Section
            Section {
                Button {
                    self.navigator.navigate(to: MoreDestination.profile)
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
                        if let url = self.viewModel.feature2URL {
                            self.navigator.navigate(to: MoreDestination.webview(url))
                        }
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
                    self.viewModel.requestSecureContent()
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
                    self.showLogoutAlert = true
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
        .onReceive(self.viewModel.$secureContentRoute) { route in
            guard let route else { return }
            self.viewModel.secureContentRoute = nil
            switch route {
                case .secret:
                    self.navigator.navigate(to: MoreDestination.secureContent)
                case .validate:
                    self.navigator.navigate(to: PinDestination.validate)
                case .enroll(let data):
                    self.navigator.navigate(to: PinDestination.enroll(data))
            }
        }
        .onChange(of: self.viewModel.didLogout) { _, didLogout in
            if didLogout { self.navigator.send(AppEvent.logout) }
        }
        .alert(Strings.Alert.LogOut.title, isPresented: self.$showLogoutAlert) {
            Button(Strings.Alert.LogOut.cancel, role: .cancel) {}
            Button(Strings.Alert.LogOut.accept, role: .destructive) {
                self.viewModel.logOut()
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
}
#endif
