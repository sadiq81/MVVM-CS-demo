
import SwiftUI

import MustacheFoundation
import MustacheServices

struct ProductDetailView: View {

    @ObservedObject
    private var viewModel: ProductDetailViewModel

    init(viewModel: ProductDetailViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                let product = self.viewModel.product
                // MARK: Product Image
                self.productImage(product)

                // MARK: Title + Favorite
                self.titleAndFavorite(product)

                // MARK: Price + Stock
                self.priceAndStock(product)

                // MARK: Rating
                self.ratingSection(product)

                // MARK: Info Boxes
                self.infoBoxes(product)

                // MARK: Description
                self.descriptionSection(product)

                // MARK: Discount
                self.discountSection(product)
            }
            .padding(.bottom, 32)
        }
        .background(Color(Colors.Background.default.color).ignoresSafeArea())
        .navigationTitle(self.viewModel.product.title)
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Subviews

    @ViewBuilder
    private func productImage(_ product: ProductModel) -> some View {
        AsyncImage(url: product.images.first ?? product.thumbnail) { phase in
            switch phase {
            case .success(let image):
                image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            case .failure:
                Image(systemName: Images.System.photo)
                    .font(.largeTitle)
                    .foregroundColor(Color(Colors.Foreground.muted.color))
                    .frame(maxWidth: .infinity)
                    .frame(height: 250)
            default:
                ProgressView()
                    .frame(maxWidth: .infinity)
                    .frame(height: 250)
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: 250)
        .clipped()
    }

    @ViewBuilder
    private func titleAndFavorite(_ product: ProductModel) -> some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 4) {
                Text(product.title)
                    .font(.title)
                    .foregroundColor(Color(Colors.Foreground.default.color))

                if !product.brand.isEmpty {
                    Text(product.brand)
                        .font(.title3)
                        .foregroundColor(Color(Colors.Foreground.muted.color))
                }

                Text(product.description)
                    .font(.body)
                    .foregroundColor(Color(Colors.Foreground.muted.color))
            }

            Spacer()

            Button(action: { self.viewModel.toggleFavorite() }) {
                Image(systemName: self.viewModel.isFavorite ? Images.System.heartFill : Images.System.heart)
                    .font(.title2)
                    .foregroundColor(self.viewModel.isFavorite
                        ? Color(Colors.Foreground.brand.color)
                        : Color(Colors.Foreground.default.color))
                    .padding(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(self.viewModel.isFavorite
                                ? Color(Colors.Foreground.brand.color)
                                : Color(Colors.Border.default.color), lineWidth: 1)
                    )
            }
        }
        .padding(.horizontal, 16)
    }

    @ViewBuilder
    private func priceAndStock(_ product: ProductModel) -> some View {
        VStack(spacing: 0) {
            Divider()

            HStack(spacing: 0) {
                HStack(spacing: 4) {
                    Image(systemName: Images.System.euroSign)
                        .foregroundColor(Color(Colors.Foreground.muted.color))
                    let price = NumberFormatter.price.string(from: product.price) ?? "-"
                    Text(Strings.Product.Details.price(price))
                        .font(.caption)
                        .foregroundColor(Color(Colors.Foreground.muted.color))
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)

                Divider()

                HStack(spacing: 4) {
                    Image(systemName: Images.System.numberSign)
                        .foregroundColor(Color(Colors.Foreground.muted.color))
                    Text(Strings.Product.Details.stock(product.stock))
                        .font(.caption)
                        .foregroundColor(Color(Colors.Foreground.muted.color))
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
            }
            .fixedSize(horizontal: false, vertical: true)

            Divider()
        }
    }

    @ViewBuilder
    private func ratingSection(_ product: ProductModel) -> some View {
        VStack(spacing: 0) {
            HStack(spacing: 8) {
                Text(Strings.Product.Details.Rating.caption)
                    .font(.caption)
                    .foregroundColor(Color(Colors.Foreground.muted.color))

                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        Rectangle()
                            .fill(Color(Colors.Background.neutralSubtle.color))
                            .frame(height: 8)
                            .cornerRadius(4)

                        Rectangle()
                            .fill(Color(Colors.Background.brand.color))
                            .frame(width: geometry.size.width * CGFloat(product.rating / 5.0), height: 8)
                            .cornerRadius(4)
                    }
                }
                .frame(height: 8)

                Text("\(product.rating, specifier: "%.2f")")
                    .font(.caption2)
                    .foregroundColor(Color(Colors.Foreground.muted.color))
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)

            Divider()
        }
    }

    @ViewBuilder
    private func descriptionSection(_ product: ProductModel) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(Strings.Product.Details.Details.caption.uppercased())
                .font(.caption)
                .foregroundColor(Color(Colors.Foreground.muted.color))

            Text(product.description)
                .font(.body)
                .foregroundColor(Color(Colors.Foreground.muted.color))
        }
        .padding(.horizontal, 16)
    }

    @ViewBuilder
    private func infoBoxes(_ product: ProductModel) -> some View {
        VStack(spacing: 8) {
            if product.stock < 10 {
                infoBox(text: Strings.Product.Details.Notice.fewProducts, color: Color(Colors.Background.attention.color))
            }
            if product.discountPercentage > 10 {
                infoBox(text: Strings.Product.Details.Notice.discount, color: Color(Colors.Background.success.color))
            }
        }
        .padding(.horizontal, 16)
    }

    @ViewBuilder
    private func infoBox(text: String, color: Color) -> some View {
        HStack {
            Text(text)
                .font(.caption)
                .foregroundColor(Color(Colors.Foreground.default.color))
            Spacer()
        }
        .padding(12)
        .background(color.opacity(0.2))
        .cornerRadius(8)
    }

    @ViewBuilder
    private func discountSection(_ product: ProductModel) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(Strings.Product.Details.Discount.caption)
                .font(.caption)
                .foregroundColor(Color(Colors.Foreground.muted.color))

            let discount = NumberFormatter.price.string(from: product.discountPercentage) ?? "-"
            Text(Strings.Product.Details.discount(discount))
                .font(.subheadline)
                .foregroundColor(Color(Colors.Foreground.muted.color))
        }
        .padding(.horizontal, 16)
    }
}

#if DEBUG
#Preview("ProductDetailView") {
    Container.shared.productService.register { PreviewProductService() }
    let viewModel = Container.shared.productDetailViewModel(.mockData)
    let view = NavigationStack {
        ProductDetailView(viewModel: viewModel)
    }
    .environmentObject(HostingCoordinator(coordinator: PreviewCoordinator()))
    return view
}
#endif
