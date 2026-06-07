

import SwiftUI

import MustacheServices

struct DashboardView: View {

    @EnvironmentObject
    private var coordinator: HostingCoordinator

    @InjectedObject(\.dashboardViewModel)
    private var viewModel

    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 0) {

                    // MARK: User Card
                    if let user = self.viewModel.user {
                        DashboardSectionHeaderView(title: "Continue")
                        UserCardView(user: user, screenWidth: geometry.size.width)
                            .padding(.horizontal, 16)
                            .padding(.bottom, 24)
                    }

                    // MARK: Comments
                    if let comments = self.viewModel.dashboard?.comments, !comments.isEmpty {
                        DashboardSectionHeaderView(title: "Comments")
                        ScrollView(.horizontal, showsIndicators: false) {
                            LazyHStack(spacing: 0) {
                                ForEach(Array(stride(from: 0, to: comments.count, by: 2)), id: \.self) { index in
                                    HStack(spacing: 0) {
                                        DashboardCardView(style: .dark) {
                                            Text(comments[index].email)
                                                .font(.body)
                                                .lineLimit(nil)
                                        }
                                        .frame(width: (geometry.size.width - 16 - 16 - 8) / 2)
                                        .padding(.leading, 16)
                                        .padding(.trailing, 4)

                                        if index + 1 < comments.count {
                                            DashboardCardView(style: .dark) {
                                                Text(comments[index + 1].email)
                                                    .font(.body)
                                                    .lineLimit(nil)
                                            }
                                            .frame(width: (geometry.size.width - 16 - 16 - 8) / 2)
                                            .padding(.leading, 4)
                                            .padding(.trailing, 16)
                                        }
                                    }
                                    .frame(width: geometry.size.width)
                                    .scrollTargetLayout()
                                }
                            }
                        }
                        .scrollTargetBehavior(.viewAligned)
                        .frame(height: geometry.size.width * 0.5)
                        .padding(.bottom, 24)
                    }

                    // MARK: Posts
                    if let posts = self.viewModel.dashboard?.posts, !posts.isEmpty {
                        DashboardSectionHeaderView(title: "Posts")
                        ScrollView(.horizontal, showsIndicators: false) {
                            LazyHStack(spacing: 8) {
                                ForEach(posts, id: \.id) { post in
                                    DashboardCardView(style: .brand) {
                                        Text(post.title)
                                            .font(.emphasizedBody)
                                            .lineLimit(nil)
                                    }
                                    .frame(width: geometry.size.width * 0.95 - 16 - 8)
                                }
                            }
                            .scrollTargetLayout()
                            .padding(.horizontal, 16)
                        }
                        .scrollTargetBehavior(.viewAligned)
                        .frame(height: geometry.size.width * 0.4)
                        .padding(.bottom, 24)
                    }

                    // MARK: Albums
                    if let albums = self.viewModel.dashboard?.albums, !albums.isEmpty {
                        DashboardSectionHeaderView(title: "Albums")
                        ScrollView(.horizontal, showsIndicators: false) {
                            LazyHStack(spacing: 12) {
                                ForEach(albums, id: \.id) { album in
                                    DashboardCardView(style: .surface) {
                                        Text(album.title)
                                            .font(.body)
                                            .lineLimit(nil)
                                    }
                                    .frame(width: geometry.size.width * 0.4)
                                }
                            }
                            .scrollTargetLayout()
                            .padding(.horizontal, 16)
                        }
                        .scrollTargetBehavior(.viewAligned)
                        .frame(height: geometry.size.width * 0.4)
                        .padding(.bottom, 24)
                    }

                    // MARK: Todos
                    if let todos = self.viewModel.dashboard?.todos, !todos.isEmpty {
                        DashboardSectionHeaderView(title: "Todos")
                        ScrollView(.horizontal, showsIndicators: false) {
                            LazyHStack(spacing: 0) {
                                ForEach(Array(stride(from: 0, to: todos.count, by: 3)), id: \.self) { index in
                                    HStack(spacing: 8) {
                                        ForEach(0..<3, id: \.self) { offset in
                                            if index + offset < todos.count {
                                                DashboardCardView(style: .neutralSubtle) {
                                                    Text(todos[index + offset].title)
                                                        .font(.body)
                                                        .lineLimit(nil)
                                                }
                                            }
                                        }
                                    }
                                    .padding(.horizontal, 16)
                                    .frame(width: geometry.size.width)
                                    .scrollTargetLayout()
                                }
                            }
                        }
                        .scrollTargetBehavior(.viewAligned)
                        .frame(height: geometry.size.width * 0.4)
                        .padding(.bottom, 24)
                    }
                }
                .padding(.top, 12)
            }
        }
        .background(Color(Colors.Background.default.color).ignoresSafeArea())
        .refreshable {
            await self.viewModel.refresh()
        }
        .navigationTitle(Strings.Tabbar.dashboard)
    }
}

// MARK: - Section Header

private struct DashboardSectionHeaderView: View {

    let title: String

    var body: some View {
        Text(self.title)
            .font(.headline)
            .foregroundColor(Color(Colors.Foreground.muted.color))
            .padding(.horizontal, 16)
            .frame(height: 40)
    }
}

// MARK: - Card Style

private enum DashboardCardStyle {
    case surface
    case dark
    case brand
    case neutralSubtle

    var backgroundColor: Color {
        switch self {
            case .surface: return Color(Colors.Background.surface.color)
            case .dark: return Color(Colors.Background.dark.color)
            case .brand: return Color(Colors.Background.brand.color)
            case .neutralSubtle: return Color(Colors.Background.neutralSubtle.color)
        }
    }

    var foregroundColor: Color {
        switch self {
            case .surface: return Color(Colors.Foreground.default.color)
            case .dark: return Color(Colors.Foreground.light.color)
            case .brand: return Color(Colors.Foreground.light.color)
            case .neutralSubtle: return Color(Colors.Foreground.default.color)
        }
    }

    var showBorder: Bool {
        switch self {
            case .surface, .neutralSubtle: return true
            case .dark, .brand: return false
        }
    }
}

// MARK: - Elevated Card

private struct DashboardCardView<Content: View>: View {

    let style: DashboardCardStyle
    let content: Content

    init(style: DashboardCardStyle = .surface, @ViewBuilder content: () -> Content) {
        self.style = style
        self.content = content()
    }

    var body: some View {
        self.content
            .foregroundColor(self.style.foregroundColor)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            .padding(16)
            .background(self.style.backgroundColor)
            .cornerRadius(Constants.Rounding.medium)
            .overlay(
                Group {
                    if self.style.showBorder {
                        RoundedRectangle(cornerRadius: Constants.Rounding.medium)
                            .stroke(Color(Colors.Border.default.color), lineWidth: 1)
                    }
                }
            )
            .shadow(color: Color.black.opacity(0.18), radius: 8, x: 0, y: 4)
            // vertical breathing room so the shadow renders inside the
            // fixed-height horizontal scrollers instead of being clipped
            .padding(.vertical, 14)
    }
}

// MARK: - User Card

private struct UserCardView: View {

    let user: UserModel
    let screenWidth: CGFloat

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if let firstName = self.user.firstName {
                Text(firstName)
                    .font(.body)
                    .foregroundColor(Color(Colors.Foreground.light.color))
            }
            if let email = self.user.email {
                Text(email)
                    .font(.subheadline)
                    .foregroundColor(Color(Colors.Foreground.lightMuted.color))
            }
            if let city = self.user.city, let country = self.user.country {
                Text("\(city), \(country)")
                    .font(.footnote)
                    .foregroundColor(Color(Colors.Foreground.lightMuted.color))
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .padding(16)
        .frame(height: self.screenWidth * (2.125 / 3.375))
        .background(Color(Colors.Background.dark.color))
        .cornerRadius(Constants.Rounding.medium)
        .shadow(color: Color.black.opacity(0.18), radius: 8, x: 0, y: 4)
    }
}

#if DEBUG
#Preview("DashboardView") {
    Container.shared.userService.register { PreviewUserService() }
    Container.shared.dashboardService.register { PreviewDashboardService() }
    return NavigationStack {
        DashboardView()
    }
    .environmentObject(HostingCoordinator(coordinator: PreviewCoordinator()))
}
#endif
