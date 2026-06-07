import Combine
import Foundation
import UIKit

import MustacheFoundation
import MustacheServices
import MustacheUIKit

final class ProductDetailsViewController: UIViewController {

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

    @IBOutlet weak var progressView: UIKitProgressView!
    
    @IBOutlet weak var ratingCaptionLabel: UILabel!
    @IBOutlet weak var ratingLabel: UILabel!

    @IBOutlet weak var longDescriptionLabel: UILabel!

    @IBOutlet weak var informationBoxFewProducts: UIView!
    @IBOutlet weak var informationBoxFewProductsLabel: UILabel!
    @IBOutlet weak var informationBoxDiscount: UIView!
    @IBOutlet weak var informationBoxDiscountLabel: UILabel!

    @IBOutlet weak var detailsCaptionLabel: UILabel!
    
    @IBOutlet weak var percentageCaptionLabel: UILabel!
    @IBOutlet weak var percentageImageView: UIImageView!
    @IBOutlet weak var percentageLabel: UILabel!
    @IBOutlet weak var priceImageView: UIImageView!
    @IBOutlet weak var stockImageView: UIImageView!

    // MARK: ViewModel

    @Injected(\.productDetailsViewModelType)
    private var viewModel: any ProductDetailsViewModelType

    // MARK: Coordinator

    var coordinator: (any CoordinatorType)!

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

    private func configureView() {
        // Set background colors
        self.view.backgroundColor = Colors.Background.default.color
        self.scrollView.backgroundColor = .clear

        self.activityIndicator.color = Colors.Foreground.brand.color

        self.toggleButton.imageView?.contentMode = .scaleAspectFit
        self.toggleButton.layer.cornerRadius = Constants.Rounding.medium
        self.toggleButton.layer.borderWidth = 1
        self.toggleButton.clipsToBounds = true

        // Apply background and rounding to the inner MView subview (which has 16pt margins)
        // The outlet references the full-width outer view; the inner subview has the inset layout
        if let innerView = self.informationBoxFewProducts.subviews.first {
            innerView.backgroundColor = Colors.Background.attention.color.withAlphaComponent(0.2)
            innerView.layer.cornerRadius = Constants.Rounding.medium
        }
        if let innerView = self.informationBoxDiscount.subviews.first {
            innerView.backgroundColor = Colors.Background.success.color.withAlphaComponent(0.2)
            innerView.layer.cornerRadius = Constants.Rounding.medium
        }

        // Caption labels with muted color
        self.ratingCaptionLabel.configure(textStyle: .caption1, text: Strings.Product.Details.Rating.caption, color: .muted)

        self.informationBoxFewProductsLabel.configure(textStyle: .caption1, text: Strings.Product.Details.Notice.fewProducts)
        self.informationBoxDiscountLabel.configure(textStyle: .caption1, text: Strings.Product.Details.Notice.discount)

        // System image tints — set in code, not storyboard
        self.priceImageView.tintColor = Colors.Foreground.muted.color
        self.stockImageView.tintColor = Colors.Foreground.muted.color

        // Discount section: hide icon and caption, reconfigure label for vertical layout
        self.percentageImageView.isHidden = true
        self.percentageCaptionLabel.isHidden = true
        self.percentageLabel.numberOfLines = 0
        if let parent = self.percentageLabel.superview {
            // Deactivate storyboard constraints (centerY to caption, trailing-only)
            for constraint in parent.constraints where
                (constraint.firstItem as? UIView == self.percentageLabel ||
                 constraint.secondItem as? UIView == self.percentageLabel) {
                constraint.isActive = false
            }
            // Pin label to fill parent (matches SwiftUI VStack leading-aligned layout)
            NSLayoutConstraint.activate([
                self.percentageLabel.leadingAnchor.constraint(equalTo: parent.leadingAnchor),
                self.percentageLabel.trailingAnchor.constraint(equalTo: parent.trailingAnchor),
                self.percentageLabel.topAnchor.constraint(equalTo: parent.topAnchor),
                self.percentageLabel.bottomAnchor.constraint(equalTo: parent.bottomAnchor)
            ])
        }
    }

    private func configureBindings() {

        Publishers.CombineLatest(self.viewModel.productPublisher, self.viewModel.favoritesProductPublisher)
            .sink { [weak self] product, favorites in
                self?.update(with: product, favorites: favorites)
            }
            .store(in: &self.cancellables)

    }
    
    fileprivate func update(with product: ProductModel, favorites: [ProductModel]) {
        self.title = product.title
        
        self.imageView.setImage(from: product.images.first ?? product.thumbnail)
        
        self.titleLabel.configure(textStyle: .title1, text: product.title, color: .default)
        self.brandLabel.configure(textStyle: .title3, text: product.brand, color: .muted)
        
        self.descriptionLabel.configure(textStyle: .body, text: product.description, color: .muted)
        
        let favorite = favorites.contains(product)
        self.toggleButton.setImage(favorite ? SFSymbol.heartFill.image : SFSymbol.heart.image, for: .normal)
        self.toggleButton.tintColor = favorite ? Colors.Foreground.brand.color : Colors.Foreground.default.color
        self.toggleButton.layer.borderColor = favorite ? Colors.Foreground.brand.color.cgColor : Colors.Border.default.color.cgColor
        
        self.toggleButton.removeAction(identifiedBy: .toggle, for: .touchUpInside)
        let toggleAction = UIAction(title: "", identifier: .toggle, handler: { [weak self] _ in self?.toggle(product) })
        self.toggleButton.addAction(toggleAction, for: .touchUpInside)
        
        let price = NumberFormatter.price.string(from: product.price)
        let priceText = Strings.Product.Details.price(price ?? "-1")
        self.priceLabel.configure(textStyle: .caption1, text: priceText, color: .muted)
        
        let stockText = Strings.Product.Details.stock(product.stock)
        self.stockLabel.configure(textStyle: .caption1, text: stockText, color: .muted)
        
        self.progressView.configure(progress: product.rating.cgfloat, maximum: 5.0)
        self.ratingLabel.configure(textStyle: .caption2, text: "\(product.rating)", color: .muted)
        
        let detailsCaption = Strings.Product.Details.Details.caption.uppercased()
        let detailsAttributedText = NSMutableAttributedString()
        detailsAttributedText.append(NSAttributedString(string: detailsCaption + "\n", attributes: [
            .font: UIFont.preferredFont(forTextStyle: .caption1),
            .foregroundColor: Colors.Foreground.muted.color
        ]))
        detailsAttributedText.append(NSAttributedString(string: product.description, attributes: [
            .font: UIFont.preferredFont(forTextStyle: .body),
            .foregroundColor: Colors.Foreground.muted.color
        ]))
        self.longDescriptionLabel.attributedText = detailsAttributedText
        self.detailsCaptionLabel.isHidden = true
        
        self.informationBoxFewProducts.isHidden = product.stock >= 10
        self.informationBoxDiscount.isHidden = product.discountPercentage <= 10
        
        let discountPercentage = NumberFormatter.price.string(from: product.discountPercentage)
        let percentageText = Strings.Product.Details.discount(discountPercentage ?? "-1")
        let discountCaption = Strings.Product.Details.Discount.caption
        let discountAttributedText = NSMutableAttributedString()
        discountAttributedText.append(NSAttributedString(string: discountCaption + "\n", attributes: [
            .font: UIFont.preferredFont(forTextStyle: .caption1),
            .foregroundColor: Colors.Foreground.muted.color
        ]))
        discountAttributedText.append(NSAttributedString(string: percentageText, attributes: [
            .font: UIFont.preferredFont(forTextStyle: .subheadline),
            .foregroundColor: Colors.Foreground.muted.color
        ]))
        self.percentageLabel.attributedText = discountAttributedText
        self.percentageCaptionLabel.isHidden = true
    }
    
    private func toggle(_ product: ProductModel) {
        self.viewModel.toggle(product: product)
    }

    // MARK: @IBActions

    @IBAction func back() {
        self.navigationController?.popViewController(animated: true)
    }
    
    // MARK: Override UIViewController functions

    override var preferredStatusBarStyle: UIStatusBarStyle { return .lightContent }

}

// MARK: Extensions
fileprivate extension UIAction.Identifier {

    static let toggle = UIAction.Identifier("\(#file)-\(#function)")

}

#if DEBUG
#Preview("ProductDetailsViewController") {
    Container.shared.productDetailsViewModelType.register { MainActor.assumeIsolated { PreviewProductDetailsViewModel() } }

    let viewController = AppStoryboard.viewController(class: ProductDetailsViewController.self)
    viewController.coordinator = UIKitPreviewCoordinator()
    return UINavigationController(rootViewController: viewController)
}
#endif
