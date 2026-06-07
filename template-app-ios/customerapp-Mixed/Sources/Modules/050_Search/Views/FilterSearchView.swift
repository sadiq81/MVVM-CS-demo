import SwiftUI

import MustacheServices

struct FilterSearchView: View {

    @EnvironmentObject
    private var coordinator: HostingCoordinator

    @InjectedObject(\.filterSearchViewModel)
    private var viewModel

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                VStack(spacing: 0) {
                    // Search bar
                    HStack {
                        Image(systemName: Images.System.search)
                            .foregroundColor(Color(Colors.Foreground.muted.color))
                        TextField(Strings.Product.Search.placehoder, text: self.$viewModel.searchText)
                            .font(.body)
                    }
                    .padding(8)
                    .background(Color(Colors.Background.surface.color))
                    .cornerRadius(8)
                    .padding(.horizontal, 16)
                    .padding(.bottom, 4)

                    if !self.viewModel.searchText.isEmpty && self.viewModel.filters.isEmpty {
                        // Empty state only when search yields no results
                        self.emptyStateView
                    } else {
                        self.filterList
                    }
                }

                // Gradient + Save button overlay
                if self.viewModel.isDirty {
                    self.gradientSaveOverlay
                }
            }
            .background(Color(Colors.Background.default.color).ignoresSafeArea())
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { self.viewModel.clear() }) {
                        Text(Strings.Product.Filter.clearFilters)
                            .font(.body)
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { try? self.coordinator.transition(to: SearchProductTransition.dismissFilter) }) {
                        Image(systemName: Images.System.close)
                    }
                }
            }
            .interactiveDismissDisabled()
        }
    }

    // MARK: - Filter List

    private var filterList: some View {
        List {
            ForEach(self.viewModel.filters.indices, id: \.self) { index in
                let filter = self.viewModel.filters[index]
                FilterToggleRow(
                    title: filter.localization,
                    isOn: Binding(
                        get: { self.viewModel.isSelected(filter: filter) },
                        set: { self.viewModel.toggle(filter: filter, isSelected: $0) }
                    )
                )
            }
        }
        .listStyle(.plain)
        .contentMargins(.bottom, 107, for: .scrollContent)
    }

    // MARK: - Empty State

    private var emptyStateView: some View {
        VStack(spacing: 8) {
            Text(Strings.Product.Filter.EmptyView.title)
                .font(.title)
                .foregroundColor(Color(Colors.Foreground.default.color))
            Text(Strings.Product.Filter.EmptyView.body)
                .font(.body)
                .foregroundColor(Color(Colors.Foreground.muted.color))
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: - Gradient + Save Button Overlay

    private var gradientSaveOverlay: some View {
        VStack(spacing: 0) {
            // Alpha gradient matching UIKit's GradientView
            LinearGradient(
                colors: [
                    Color(Colors.Background.default.color).opacity(0),
                    Color(Colors.Background.default.color)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(height: 40)

            // Save button on solid background
            Button(action: {
                self.viewModel.save()
                try? self.coordinator.transition(to: SearchProductTransition.dismissFilter)
            }) {
                Text(Strings.Product.Filter.Button.title)
            }
            .buttonStyle(PrimaryButtonStyle())
            .padding(.horizontal, 16)
            .padding(.bottom, 16)
            .background(Color(Colors.Background.default.color))
        }
    }
}

// MARK: - Filter Toggle Row

private struct FilterToggleRow: View {

    let title: String
    @Binding var isOn: Bool

    var body: some View {
        Toggle(isOn: self.$isOn) {
            Text(self.title)
                .font(.body)
                .foregroundColor(Color(Colors.Foreground.default.color))
        }
        .tint(Color(Colors.Background.brand.color))
        .listRowBackground(Color(Colors.Background.default.color))
    }
}

#if DEBUG
#Preview("FilterSearchView") {
    Container.shared.filtersService.register { PreviewFiltersService() }
    // Register a fresh preview view model (created after the preview filters
    // service) with the filter type set, so `configure()` populates the brand
    // list from PreviewFiltersService. Registering (rather than mutating the
    // shared instance) avoids a stale cached VM bound to the real service.
    Container.shared.filterSearchViewModel.register {
        MainActor.assumeIsolated {
            let viewModel = FilterSearchViewModel()
            viewModel.filterType = .brand
            return viewModel
        }
    }
    return NavigationStack {
        FilterSearchView()
            .environmentObject(HostingCoordinator(coordinator: PreviewCoordinator()))
    }
}
#endif
