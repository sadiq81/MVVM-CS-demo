
import SwiftUI

import MustacheFoundation
import MustacheServices
import NavigatorUI

struct ProductSearchView: View {

    @State private var isSearchExpanded = false

    @SwiftUI.Environment(\.navigator)
    private var navigator: Navigator

    @InjectedObject(\.productSearchViewModel)
    private var viewModel

    var body: some View {
        VStack(spacing: 0) {

            // MARK: Search + Filter Chips
            self.searchAndFilterBar

            // MARK: Product List
            self.productList
        }
        .background(Color(Colors.Background.default.color).ignoresSafeArea())
        .navigationTitle(Strings.Tabbar.search)
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Search Bar + Filter Chips

    private var searchAndFilterBar: some View {
        HStack(spacing: 0) {
            // Search button / expanded search field
            HStack(spacing: 0) {
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        self.isSearchExpanded.toggle()
                        if !self.isSearchExpanded {
                            self.viewModel.searchText = ""
                        }
                    }
                }) {
                    Image(systemName: Images.System.search)
                        .font(.body)
                        .foregroundColor(Color(Colors.Foreground.muted.color))
                        .frame(width: 20, height: 20)
                        .padding(8)
                }
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color(Colors.Background.neutralSubtle.color))
                )

                if self.isSearchExpanded {
                    TextField(Strings.Product.Search.placehoder, text: self.$viewModel.searchText)
                        .font(.body)
                        .transition(.opacity)
                }
            }
            .padding(.leading, 16)
            .padding(.trailing, 8)

            if !self.isSearchExpanded {
                // Filter chips
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(ProductFilterType.allCases, id: \.rawValue) { filterType in
                            FilterChipView(
                                filterType: filterType,
                                selectedNames: self.selectedNames(for: filterType)
                            ) {
                                self.navigator.navigate(to: SearchDestination.filter(filterType))
                            }
                        }
                    }
                    .padding(.trailing, 16)
                }
                .transition(.opacity)
            }
        }
        .frame(height: 48)
    }

    private func selectedNames(for type: ProductFilterType) -> [String] {
        switch type {
            case .brand:
                return self.viewModel.selectedBrands.map(\.localization)
            case .category:
                return self.viewModel.selectedCategories.map(\.localization)
        }
    }

    // MARK: - Product List

    private var productList: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 0) {
                ForEach(self.viewModel.groupedProducts, id: \.brand) { group in
                    // Section header
                    Text(group.brand.isEmpty ? Strings.Product.Header.NoBrand.title : group.brand)
                        .font(.body)
                        .foregroundColor(Color(Colors.Foreground.muted.color))
                        .padding(.horizontal, 16)
                        .padding(.vertical, 6)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color(Colors.Background.default.color))

                    ForEach(group.products, id: \.id) { product in
                        ProductCardView(product: product)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 6)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                self.navigator.navigate(to: SearchDestination.details(product))
                            }
                    }
                }

                if self.viewModel.hasPlaceholders {
                    HStack {
                        Spacer()
                        ProgressView()
                            .padding()
                        Spacer()
                    }
                    .onAppear {
                        if self.viewModel.searchResults?.products.count != nil {
                            self.viewModel.fetchMore(item: self.viewModel.products.count)
                        }
                    }
                }
            }
        }
        .refreshable {
            self.viewModel.refresh()
        }
    }
}

// MARK: - Filter Chip

private struct FilterChipView: View {

    let filterType: ProductFilterType
    let selectedNames: [String]
    let action: () -> Void

    private var buttonText: String {
        switch self.selectedNames.count {
            case 0:
                return Strings.Filter.all
            case 1:
                return self.selectedNames.first ?? Strings.Filter.all
            default:
                return Strings.Filter.selected(self.selectedNames.count)
        }
    }

    private var isSelected: Bool {
        return !self.selectedNames.isEmpty
    }

    var body: some View {
        Button(action: self.action) {
            HStack(spacing: 4) {
                Text("\(self.filterType.localization):")
                    .font(.callout)
                    .foregroundColor(Color(Colors.Foreground.default.color))

                Text(self.buttonText)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(self.isSelected
                        ? Color(Colors.Background.brand.color)
                        : Color.clear)
                    .foregroundColor(Color(Colors.Foreground.default.color))
                    .cornerRadius(4)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(Color(Colors.Background.neutralSubtle.color))
            .overlay(
                RoundedRectangle(cornerRadius: 18)
                    .stroke(Color(Colors.Border.default.color), lineWidth: self.isSelected ? 0 : 1)
            )
            .cornerRadius(18)
        }
    }
}

// MARK: - Product Card

struct ProductCardView: View {

    let product: ProductModel

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            // Thumbnail
            AsyncImage(url: self.product.thumbnail) { phase in
                switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    case .failure:
                        Image(systemName: Images.System.photo)
                            .foregroundColor(Color(Colors.Foreground.muted.color))
                    default:
                        ProgressView()
                }
            }
            .frame(width: 80, height: 80)
            .background(Color(Colors.Background.neutralSubtle.color))
            .cornerRadius(Constants.Rounding.small)
            .clipped()

            // Content
            VStack(alignment: .leading, spacing: 4) {
                Text(self.product.title)
                    .font(.body)
                    .fontWeight(.semibold)
                    .foregroundColor(Color(Colors.Foreground.default.color))
                    .lineLimit(1)

                Text(self.product.description)
                    .font(.body)
                    .foregroundColor(Color(Colors.Foreground.muted.color))
                    .lineLimit(3)
            }

            Spacer(minLength: 0)

            // Price + Rating
            VStack(alignment: .trailing, spacing: 4) {
                PriceTextView(price: self.product.price)

                HStack(spacing: 2) {
                    Image(systemName: "star")
                        .font(.caption2)
                        .foregroundColor(Color(Colors.Foreground.brand.color))
                    Text(String(format: "%.2f", self.product.rating))
                        .font(.caption)
                        .foregroundColor(Color(Colors.Foreground.muted.color))
                }
            }
        }
        .padding(12)
        .background(Color(Colors.Background.surface.color))
        .cornerRadius(Constants.Rounding.medium)
        .overlay(
            RoundedRectangle(cornerRadius: Constants.Rounding.medium)
                .stroke(Color(Colors.Border.default.color), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.18), radius: 8, x: 0, y: 4)
    }
}

// MARK: - Price Text

struct PriceTextView: View {

    let price: Double

    private var integerPart: String {
        return NumberFormatter.integer.string(from: self.price) ?? "0"
    }

    private var decimalPart: String {
        let full = NumberFormatter.decimal.string(from: self.price) ?? "00"
        return String(full.dropFirst())
    }

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 0) {
            Text(self.integerPart)
                .font(.title)
                .foregroundColor(Color(Colors.Foreground.default.color))
            Text(self.decimalPart)
                .font(.caption)
                .foregroundColor(Color(Colors.Foreground.default.color))
        }
    }
}

#if DEBUG
#Preview("ProductSearchView") {
    Container.shared.productService.register { PreviewProductService() }
    Container.shared.filtersService.register { PreviewFiltersService() }
    // Pre-populate results synchronously so the snapshot renders products
    // (production fetch is async/debounced and won't complete for a static snapshot).
    let viewModel = Container.shared.productSearchViewModel()
    viewModel.searchResults = ProductSearchResult.mockData
    return NavigationStack {
        ProductSearchView()
    }
}
#endif
