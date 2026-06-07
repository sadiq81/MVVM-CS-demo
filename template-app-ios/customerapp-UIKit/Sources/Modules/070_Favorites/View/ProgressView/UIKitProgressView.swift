import Foundation
import UIKit

import MustacheUIKit

@IBDesignable
final class UIKitProgressView: UIView {

    @IBOutlet var contentView: UIView!
    @IBOutlet weak var statusProgress: UIView!
    @IBOutlet var statusWidthConstraint: NSLayoutConstraint!

    var progress: CGFloat?
    var maximum: CGFloat?

    convenience init() {
        self.init(frame: .zero)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.configureView()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.configureView()
    }

    fileprivate func configureView() {
        self.contentView = self.configureNibView(bundle: .main)
        self.contentView.clipsToBounds = true
        self.backgroundColor = Colors.Background.neutralSubtle.color
    }

    func configure(progress: CGFloat, maximum: CGFloat) {
        self.progress = progress
        self.maximum = maximum

        let multiplier = progress / maximum
        self.statusWidthConstraint = self.statusWidthConstraint.setMultiplier(multiplier: multiplier)
        self.statusProgress.backgroundColor = Colors.Background.brand.color
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        self.layer.cornerRadius = self.frame.height / 2
        self.contentView.layer.cornerRadius = self.contentView.frame.height / 2

        guard let progress = self.progress, let maximum = self.maximum else { return }

        let multiplier = progress / maximum
        self.statusWidthConstraint = self.statusWidthConstraint.setMultiplier(multiplier: multiplier)

    }
}

#if DEBUG
#Preview("UIKitProgressView") {
    let view = UIKitProgressView(frame: CGRect(x: 0, y: 0, width: 375, height: 18))
    view.configure(progress: 0.65, maximum: 1.0)
    return view
}
#endif
