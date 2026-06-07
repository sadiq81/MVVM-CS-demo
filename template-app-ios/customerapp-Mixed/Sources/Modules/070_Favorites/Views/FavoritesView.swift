
import SwiftUI

import MustacheServices

struct FavoritesView: View {

    @EnvironmentObject
    private var coordinator: HostingCoordinator
    
    @InjectedObject(\.favoritesViewModel)
    private var viewModel

    var body: some View {
        VStack(spacing: 0) {

            // MARK: Segment Control
            Picker("Segment", selection: self.$viewModel.segmentState) {
                Text(self.viewModel.amCount >= 1 ? Strings.Product.Segment.Am.button(self.viewModel.amCount) : Strings.Product.Segment.Am.buttonEmpty)
                    .tag(SegmentState.am)
                Text(self.viewModel.nzCount >= 1 ? Strings.Product.Segment.Nz.button(self.viewModel.nzCount) : Strings.Product.Segment.Nz.buttonEmpty)
                    .tag(SegmentState.nz)
            }
            .pickerStyle(.segmented)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .onAppear {
                UISegmentedControl.appearance().selectedSegmentTintColor = Colors.Background.brand.color
                UISegmentedControl.appearance().setTitleTextAttributes([.foregroundColor: Colors.Foreground.light.color], for: .selected)
                UISegmentedControl.appearance().setTitleTextAttributes([.foregroundColor: Colors.Foreground.default.color], for: .normal)
            }

            // MARK: Content
            if self.viewModel.favorites.isEmpty {
                self.emptyStateView
            } else {
                self.favoriteListView
            }
        }
        .background(Color(Colors.Background.default.color).ignoresSafeArea())
        .navigationTitle(Strings.Tabbar.entities)
    }

    // MARK: - Empty State

    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Spacer()
            Image(systemName: Images.System.heartSlash)
                .font(.system(size: 48))
                .foregroundColor(Color(Colors.Foreground.muted.color))
            Text(Strings.Product.Details.EmptyView.title)
                .font(.emphasizedTitle2)
                .foregroundColor(Color(Colors.Foreground.default.color))
                .multilineTextAlignment(.center)
            Button(Strings.Product.Details.EmptyView.button) {
                try? self.coordinator.transition(to: TabBarTransition.search)
            }
            .buttonStyle(PrimaryButtonStyle())
            Spacer()
        }
        .padding(.horizontal, 16)
    }

    // MARK: - Favorite List

    private var favoriteListView: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(self.viewModel.favorites, id: \.id) { product in
                    ProductCardView(product: product)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            try? self.coordinator.transition(to: FavoriteTransition.details(product))
                        }
                }
            }
            .padding(.horizontal, 16)
        }
        .refreshable {}
    }
}

#if DEBUG
#Preview("FavoritesView") {
    Container.shared.productService.register { PreviewProductService() }
    return NavigationStack {
        FavoritesView()
    }
    .environmentObject(HostingCoordinator(coordinator: PreviewCoordinator()))
}
#endif
