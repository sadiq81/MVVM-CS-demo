
import SwiftUI

import MustacheServices
import NavigatorUI

// MARK: - Tab Bar Index

enum TabBarIndex: Hashable {
    case dashboard
    case search
    case favorites
    case more
}

// MARK: - Tab Bar View

struct TabBarView: View {

    @State private var selectedTab: TabBarIndex = .dashboard

    var body: some View {
        TabView(selection: self.$selectedTab) {
            ManagedNavigationStack(scene: "dashboard") {
                DashboardView()
            }
            .tabItem {
                Label(Strings.Tabbar.dashboard, systemImage: Images.System.dashboard)
            }
            .tag(TabBarIndex.dashboard)

            ManagedNavigationStack(scene: "search") {
                ProductSearchView()
            }
            .tabItem {
                Label(Strings.Tabbar.search, systemImage: Images.System.search)
            }
            .tag(TabBarIndex.search)

            ManagedNavigationStack(scene: "favorites") {
                FavoritesView()
            }
            .tabItem {
                Label(Strings.Tabbar.entities, systemImage: Images.System.favorites)
            }
            .tag(TabBarIndex.favorites)

            ManagedNavigationStack(scene: "more") {
                MoreView()
            }
            .tabItem {
                Label(Strings.Tabbar.more, systemImage: Images.System.more)
            }
            .tag(TabBarIndex.more)
        }
        .accentColor(Color(Colors.Foreground.brand.color))
        .onNavigationReceive(assign: self.$selectedTab)
    }
}

#if DEBUG
#Preview("TabBarView", traits: .fixedLayout(width: 402, height: 874)) {
    // Register Preview services for every tab so each tab's content
    // renders without hitting the network or crashing.
    Container.shared.userService.register { PreviewUserService() }
    Container.shared.dashboardService.register { PreviewDashboardService() }
    Container.shared.productService.register { PreviewProductService() }
    Container.shared.filtersService.register { PreviewFiltersService() }
    Container.shared.loginService.register { PreviewLoginService() }
    return TabBarView()
}
#endif
