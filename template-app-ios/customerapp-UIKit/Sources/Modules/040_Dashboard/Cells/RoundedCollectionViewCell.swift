import UIKit

final class RoundedCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var label: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        MainActor.assumeIsolated { self.configure() }
    }

    private func configure() {
        self.contentView.styleAsCard(style: .elevated, cornerRadius: Constants.Rounding.medium)
        self.contentView.layoutMargins = .cardPaddingLarge
    }

    func applyCardStyle(backgroundColor: UIColor, textColor: UIColor, showBorder: Bool = true) {
        self.contentView.backgroundColor = backgroundColor
        self.contentView.layer.borderWidth = showBorder ? 1 : 0
        self.label.textColor = textColor
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        self.contentView.styleAsCard(style: .elevated, cornerRadius: Constants.Rounding.medium)
    }

}

#if DEBUG
#Preview("RoundedCollectionViewCell") {
    let nib = UINib(nibName: "RoundedCollectionViewCell", bundle: .main)
    let cell = nib.instantiate(withOwner: nil).first as! RoundedCollectionViewCell
    cell.frame = CGRect(x: 0, y: 0, width: 375, height: 80)
    cell.label.text = "Dashboard Item"
    return cell
}
#endif
