import Combine
import UIKit

import MustacheServices
import MustacheUIKit

final class ProductFilterTypeCell: UICollectionViewCell {
    
    @IBOutlet weak var roundedView: MView!
    @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet weak var selectionButton: UIButton!
    
    @LazyInjected(\.filterViewModelType)
    private var viewModel: any FilterViewModelType
    
    private var cancellable = Set<AnyCancellable>()
    
    func configure(with filter: ProductFilterType) {
        
        self.cancellable = Set<AnyCancellable>()
        
        let typeText = filter.localization.appending(":")
        self.typeLabel.configure(textStyle: .callout, text: typeText)
        
        self.viewModel.selectedPublisher(for: filter)
            .sink { names in
                switch names.count {
                    case 0:
                        self.selectionButton.setTitle(Strings.Filter.all)
                        self.configureAsNormal()
                    case 1:
                        self.selectionButton.setTitle(names.first?.localization)
                        self.configureAsHighlighted()
                    default:
                        self.selectionButton.setTitle(Strings.Filter.selected(names.count))
                        self.configureAsHighlighted()
                }
                //TODO: Find a better that does not involve the cell knowing about its view heirachy
                self.setNeedsLayout()
                self.parentView(ofType: UICollectionView.self)?.collectionViewLayout.invalidateLayout()
            }
            .store(in: &self.cancellable)
        
    }
    
    private func configure() {
        self.roundedView.layer.cornerRadius = 18
        self.selectionButton.layer.cornerRadius = 4
        self.selectionButton.clipsToBounds = true
        self.selectionButton.titleLabel?.textColor = Colors.Foreground.default.color
        self.selectionButton.titleLabel?.font = UIFont.preferredFont(forTextStyle: .caption1.emphasized)
    }

    private func configureAsHighlighted() {
        self.roundedView.layer.borderWidth = 0

        self.typeLabel.textColor = Colors.Foreground.default.color
        self.selectionButton.backgroundColor = Colors.Background.brand.color
        self.selectionButton.setTitleColor(Colors.Foreground.default.color)
    }

    private func configureAsNormal() {
        self.roundedView.backgroundColor = Colors.Background.neutralSubtle.color
        self.roundedView.layer.borderColor = Colors.Border.default.color.cgColor
        self.roundedView.layer.borderWidth = 1

        self.typeLabel.textColor = Colors.Foreground.default.color
        self.selectionButton.backgroundColor = .clear
        self.selectionButton.setTitleColor(Colors.Foreground.default.color)
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        self.configureAsNormal()
        self.selectionButton.setTitle(nil)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        MainActor.assumeIsolated { self.configure() }
    }

}

#if DEBUG
#Preview("ProductFilterTypeCell") {
    let nib = UINib(nibName: "ProductFilterTypeCell", bundle: .main)
    let cell = nib.instantiate(withOwner: nil).first as! ProductFilterTypeCell
    cell.frame = CGRect(x: 0, y: 0, width: 375, height: 50)
    cell.typeLabel.text = "Category:"
    cell.selectionButton.setTitle("All", for: .normal)
    return cell
}
#endif
