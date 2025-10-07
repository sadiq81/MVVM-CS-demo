
import UIKit

class AddressSuggestionCell: UICollectionViewCell {
    
    @IBOutlet weak var suggestionLabel: UILabel!
    @IBOutlet weak var typeImageView: UIImageView!

    func configure(with model: AddressSuggestionModel) {
        self.suggestionLabel.configure(textStyle: .body, text: model.forslagstekst, color: .default)
        self.typeImageView.image = model.type.indicator
        self.typeImageView.tintColor = Colors.Foreground.muted.color
    }

}

extension AddressSuggestionCell {
    
    static let height: CGFloat = 44
}

extension AddressSuggestionType {
    
    var indicator: UIImage? {
        switch self {
            case .vejnavn: return UIImage(systemName: "chevron.right")
            case .adresse: return UIImage(systemName: "checkmark")
            case .adgangsadresse: return UIImage(systemName: "chevron.right")
            case .unknown: return nil
        }
    }
}
