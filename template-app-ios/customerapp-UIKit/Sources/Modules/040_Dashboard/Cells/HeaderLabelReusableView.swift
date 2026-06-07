import UIKit

final class HeaderLabelReusableView: UICollectionReusableView {

    @IBOutlet weak var label: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        MainActor.assumeIsolated { self.configureView() }
    }

    private func configureView() {
        // Section headers should use muted color by default
        self.backgroundColor = .clear
    }

}

#if DEBUG
#Preview("HeaderLabelReusableView") {
    let nib = UINib(nibName: "HeaderLabelReusableView", bundle: .main)
    let view = nib.instantiate(withOwner: nil).first as! HeaderLabelReusableView
    view.frame = CGRect(x: 0, y: 0, width: 375, height: 44)
    view.label.text = "Dashboard Section"
    return view
}
#endif
