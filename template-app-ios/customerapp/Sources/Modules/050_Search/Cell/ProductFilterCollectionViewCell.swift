import UIKit

class ProductFilterCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var filterSwitch: UISwitch!

    override func awakeFromNib() {
        super.awakeFromNib()
        self.configureCell()
    }

    private func configureCell() {
        // Brand color for switch
        self.filterSwitch.onTintColor = Colors.Background.brand.color
    }

    func configure(filter: any ProductFilter, isSelected: Bool) {
        self.titleLabel.configure(textStyle: .body, text: filter.localization, color: .default)
        self.filterSwitch.isOn = isSelected
    }
}
