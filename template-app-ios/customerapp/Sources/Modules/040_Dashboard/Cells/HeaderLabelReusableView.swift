import UIKit

class HeaderLabelReusableView: UICollectionReusableView {

    @IBOutlet weak var label: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        self.configureView()
    }

    private func configureView() {
        // Section headers should use muted color by default
        self.backgroundColor = .clear
    }

}
