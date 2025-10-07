import Foundation
import Combine

import MustacheUIKit
import MustacheServices

class ProductDetailsViewController: UIViewController {

    // MARK: @IBOutlets

    @IBOutlet weak var scrollView: UIScrollView!

    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var imageView: UIImageView!

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var brandLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!

    @IBOutlet weak var toggleButton: UIButton!

    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var stockLabel: UILabel!

    @IBOutlet weak var progressView: ProgressView!
    
    @IBOutlet weak var ratingCaptionLabel: UILabel!
    @IBOutlet weak var ratingLabel: UILabel!

    @IBOutlet weak var longDescriptionLabel: UILabel!

    @IBOutlet weak var informationBoxFewProducts: UIView!
    @IBOutlet weak var informationBoxFewProductsLabel: UILabel!
    @IBOutlet weak var informationBoxDiscount: UIView!
    @IBOutlet weak var informationBoxDiscountLabel: UILabel!

    @IBOutlet weak var detailsCaptionLabel: UILabel!
    
    @IBOutlet weak var percentageCaptionLabel: UILabel!
    @IBOutlet weak var percentageLabel: UILabel!

    // MARK: ViewModel

    @Injected
    var viewModel: ProductDetailsViewModelType

    // MARK: Coordinator

    var coordinator: CoordinatorType!

    // MARK: Delegate

    // MARK: Cancellable

    private var cancellables = Set<AnyCancellable>()

    // MARK: UI State Variables (Avoid if possible)

    var refreshControl = UIRefreshControl()

    // MARK: LifeCycle

    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureView()
        self.configureBindings()
    }

    // MARK: Configure

    func configureView() {
        // Set background colors
        self.view.backgroundColor = Colors.Background.default.color
        self.scrollView.backgroundColor = .clear

        self.toggleButton.imageView?.contentMode = .scaleAspectFit

        // Caption labels with muted color
        self.ratingCaptionLabel.configure(textStyle: .caption1, text: Strings.Product.Details.Rating.caption, color: .muted)

        self.informationBoxFewProductsLabel.configure(textStyle: .caption1, text: Strings.Product.Details.Notice.fewProducts)
        self.informationBoxDiscountLabel.configure(textStyle: .caption1, text: Strings.Product.Details.Notice.discount)

        self.detailsCaptionLabel.configure(textStyle: .caption1, text: Strings.Product.Details.Details.caption.uppercased(), color: .muted)

        self.percentageCaptionLabel.configure(textStyle: .caption1, text: Strings.Product.Details.Discount.caption, color: .muted)
    }

    func configureBindings() {

        Publishers.CombineLatest(self.viewModel.productPublisher, self.viewModel.favoritesProductPublisher)
            .sink { [weak self] product, favorites in
                guard let self else { return }
                self.title = product.title

                self.imageView.setImage(from: product.images.first ?? product.thumbnail)
                
                self.titleLabel.configure(textStyle: .title1, text: product.title, color: .default)
                self.brandLabel.configure(textStyle: .title3, text: product.brand, color: .muted)

                self.descriptionLabel.configure(textStyle: .body, text: product.description, color: .muted)
                
                let favorite = favorites.contains(product)
                self.toggleButton.setImage(favorite ? SFSymbol.heartFill.image : SFSymbol.heart.image, for: .normal)
                self.toggleButton.tintColor = favorite ? Colors.Foreground.brand.color : UIColor.black
                self.toggleButton.layer.borderColor = favorite ? Colors.Foreground.brand.color.cgColor : Colors.Border.default.color.cgColor

                self.toggleButton.removeAction(identifiedBy: .toggle, for: .touchUpInside)
                let toggleAction = UIAction(title: "", identifier: .toggle, handler: { _ in self.self.toggle(product) })
                self.toggleButton.addAction(toggleAction, for: .touchUpInside)

                let price = NumberFormatter.price.string(from: product.price)
                let priceText = Strings.Product.Details.price(price ?? "-1")
                self.priceLabel.configure(textStyle: .caption1, text: priceText, color: .muted)

                let stockText = Strings.Product.Details.stock(product.stock)
                self.stockLabel.configure(textStyle: .caption1, text: stockText, color: .muted)

                self.progressView.configure(progress: product.rating.cgfloat, maximum: 5.0)
                self.ratingLabel.configure(textStyle: .caption2, text: "⭐️ \(product.rating)", color: .muted)

                self.longDescriptionLabel.configure(textStyle: .body, text: Lorem.paragraphs(5), color: .muted)

                self.informationBoxFewProducts.isHidden = product.stock < 10
                self.informationBoxDiscount.isHidden = product.discountPercentage > 10

                let discountPercentage = NumberFormatter.price.string(from: product.discountPercentage)
                let percentageText = Strings.Product.Details.discount(discountPercentage ?? "-1")
                self.percentageLabel.configure(textStyle: .subheadline, text: percentageText, color: .muted)

            }
            .store(in: &self.cancellables)

    }

    // MARK: @IBActions

    @IBAction func back() {
        self.navigationController?.popViewController(animated: true)
    }

    func toggle(_ product: ProductModel) {
        self.viewModel.toggle(product: product)
    }

    // MARK: Override UIViewController functions

    override var preferredStatusBarStyle: UIStatusBarStyle { return .lightContent }

}

// MARK: Extensions
fileprivate extension UIAction.Identifier {

    static let toggle = UIAction.Identifier("\(#file)-\(#function)")

}
