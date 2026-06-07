import UIKit

import MustacheUIKit

final class ProductCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var priceView: PriceView!
    @IBOutlet weak var ratingLabel: UILabel!
    @IBOutlet weak var thumbnailImageView: UIImageView!
    
    @IBOutlet weak var seperator: UIView!

    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.configureCell()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        // Note: IBOutlets are not connected yet here — configureCell() runs in awakeFromNib() instead.
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        MainActor.assumeIsolated { self.configureCell() }
    }

    private func configureCell() {
        // Apply card styling
        self.contentView.styleAsCard(style: .elevated, cornerRadius: Constants.Rounding.medium)
        self.contentView.layoutMargins = .cardPaddingMedium

        // Card shadow to match SwiftUI
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOpacity = 0.08
        self.layer.shadowRadius = 4
        self.layer.shadowOffset = CGSize(width: 0, height: 2)
        self.layer.masksToBounds = false
        self.clipsToBounds = false

        // Separator color
        self.seperator.backgroundColor = Colors.Border.default.color

        // Activity indicator brand color
        self.activityIndicator.color = Colors.Foreground.brand.color

        // Thumbnail container background to match SwiftUI
        self.thumbnailImageView.tintColor = Colors.Foreground.brand.color
        self.thumbnailImageView.clipsToBounds = true
        if let thumbnailContainer = self.thumbnailImageView.superview?.superview {
            thumbnailContainer.backgroundColor = Colors.Background.neutralSubtle.color
            thumbnailContainer.layer.cornerRadius = Constants.Rounding.small
            thumbnailContainer.clipsToBounds = true
        }
    }

    func configure(with model: ProductModel) {
        // Title emphasized with default color
        self.titleLabel.configure(textStyle: .body.emphasized, text: model.title, color: .default)

        // Description with muted color for hierarchy
        self.descriptionLabel.configure(textStyle: .body, text: model.description, color: .muted)

        self.priceView.price = model.price
        self.priceView.isHidden = false

        // Rating with muted color
        let ratingText = "⭐️ \(model.rating)"
        self.ratingLabel.configure(textStyle: .caption1, text: ratingText, color: .muted)

        self.thumbnailImageView.setImage(from: model.thumbnail)
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        self.titleLabel.text = "\t\t"
        self.descriptionLabel.text = "\t\t\n\t\t\n\t\t\n"

        self.priceView.isHidden = true

        self.ratingLabel.text = "\t\t"

        self.thumbnailImageView.cancelImageLoad()
        self.thumbnailImageView.image = SFSymbol.cameraFill.image
    }

}

#if DEBUG
#Preview("ProductCollectionViewCell", traits: .fixedLayout(width: 375, height: 120)) {
    let nib = UINib(nibName: "ProductCollectionViewCell", bundle: .main)
    let cell = nib.instantiate(withOwner: nil).first as! ProductCollectionViewCell
    cell.frame = CGRect(x: 0, y: 0, width: 375, height: 100)
    cell.configure(with: ProductModel.mockData)
    return cell
}
#endif
