import UIKit

class RoundedCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var label: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        self.configure()
    }
    
    private func configure() {
        self.contentView.styleAsCard(style: .elevated, cornerRadius: Constants.Rounding.medium)
        self.contentView.layoutMargins = .cardPaddingLarge

    }
    
}
