import UIKit

final class ProductFilterCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var filterSwitch: UISwitch!

    override func awakeFromNib() {
        super.awakeFromNib()
        MainActor.assumeIsolated { self.configureCell() }
    }
    
    private func configureCell() {
        // Brand color for switch on-state only, keep system defaults for everything else
        self.filterSwitch.onTintColor = Colors.Background.brand.color
    }

    func configure(filter: any ProductFilter, isSelected: Bool) {
        self.titleLabel.configure(textStyle: .body, text: filter.localization, color: .default)
        self.filterSwitch.isOn = isSelected
    }
}

#if DEBUG
#Preview("ProductFilterCollectionViewCell") {
    let nib = UINib(nibName: "ProductFilterCollectionViewCell", bundle: .main)
    let cell = nib.instantiate(withOwner: nil).first as! ProductFilterCollectionViewCell
    cell.frame = CGRect(x: 0, y: 0, width: 375, height: 60)
    cell.configure(filter: BrandFilter.mockData, isSelected: true)
    return cell
}
#endif
