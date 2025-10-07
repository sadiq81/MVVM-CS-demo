import UIKit

import MustacheUIKit

class ProductCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var priceView: PriceView!
    @IBOutlet weak var ratingLabel: UILabel!
    @IBOutlet weak var thumbnailImageView: UIImageView!
    
    @IBOutlet weak var seperator: UIView!

    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

    override init(frame: CGRect) {
        super.init(frame: frame)
        configureCell()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        configureCell()
    }

    private func configureCell() {
        // Apply card styling
        self.contentView.styleAsCard(style: .elevated, cornerRadius: Constants.Rounding.medium)
        self.contentView.layoutMargins = .cardPaddingMedium

        // Separator color
        self.seperator.backgroundColor = Colors.Border.default.color

        // Thumbnail background for better separation
        self.thumbnailImageView.backgroundColor = Colors.Background.neutralSubtle.color
        self.thumbnailImageView.layer.cornerRadius = Constants.Rounding.small
        self.thumbnailImageView.clipsToBounds = true
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

        self.thumbnailImageView.kf.cancelDownloadTask()
        self.thumbnailImageView.image = SFSymbol.cameraFill.image
    }

}
