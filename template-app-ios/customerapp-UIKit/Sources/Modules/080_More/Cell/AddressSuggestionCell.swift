
import UIKit

final class AddressSuggestionCell: UICollectionViewCell {
    
    @IBOutlet weak var suggestionLabel: UILabel!
    @IBOutlet weak var typeImageView: UIImageView!
    @IBOutlet weak var separator: UIView!

    override func awakeFromNib() {
        super.awakeFromNib()
        MainActor.assumeIsolated { self.configureCell() }
    }

    private func configureCell() {
        self.separator.backgroundColor = Colors.Border.default.color
        self.typeImageView.tintColor = Colors.Foreground.default.color
    }

    func configure(with model: AddressSuggestionModel) {
        self.suggestionLabel.configure(textStyle: .body, text: model.suggestionText, color: .default)
        self.typeImageView.image = model.type.indicator
    }

}

extension AddressSuggestionCell {
    
    static let height: CGFloat = 44
}

extension AddressSuggestionType {

    var indicator: UIImage? {
        switch self {
            case .streetName: return UIImage(systemName: Images.System.forward)
            case .address: return UIImage(systemName: Images.System.checkmark)
            case .accessAddress: return UIImage(systemName: Images.System.forward)
            case .unknown: return nil
        }
    }
}

#if DEBUG
#Preview("AddressSuggestionCell") {
    let nib = UINib(nibName: "AddressSuggestionCell", bundle: .main)
    let cell = nib.instantiate(withOwner: nil).first as! AddressSuggestionCell
    cell.frame = CGRect(x: 0, y: 0, width: 375, height: AddressSuggestionCell.height)
    cell.configure(with: AddressSuggestionModel.mockData)
    return cell
}
#endif
