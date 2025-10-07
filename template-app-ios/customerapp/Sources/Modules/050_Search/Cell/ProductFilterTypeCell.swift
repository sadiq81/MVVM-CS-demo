import UIKit
import MustacheUIKit
import Combine

import MustacheUIKit
import MustacheServices

class ProductFilterTypeCell: UICollectionViewCell {
    
    @IBOutlet weak var roundedView: MView!
    @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet weak var selectionButton: UIButton!
    
    @LazyInjected
    private var viewModel: FilterViewModelType
    
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
                self.setNeedsLayout()
                self.parentView(ofType: UICollectionView.self)?.collectionViewLayout.invalidateLayout()
            }
            .store(in: &self.cancellable)
        
    }
    
    private func configure() {
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
        self.configure()
    }

}
