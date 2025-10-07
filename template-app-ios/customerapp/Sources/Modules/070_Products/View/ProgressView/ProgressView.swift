import Foundation
import UIKit
import MustacheUIKit

@IBDesignable
class ProgressView: UIView {

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
        self.contentView.layer.borderWidth = 1
        self.contentView.layer.borderColor = Colors.Border.default.color.cgColor
        self.contentView.layer.cornerRadius = 9
        self.backgroundColor = Colors.Background.neutralSubtle.color
    }

    func configure(progress: CGFloat, maximum: CGFloat) {
        self.progress = progress
        self.maximum = maximum

        let multiplier = progress / maximum
        self.statusWidthConstraint = self.statusWidthConstraint.setMultiplier(multiplier: multiplier)

        switch progress {
            case 0:
                self.contentView.backgroundColor = .red
            case 0.0..<0.25:
                self.contentView.backgroundColor = .orange
            case 0.26..<0.50:
                self.contentView.backgroundColor = .yellow
            case 0.50..<0.75:
                self.contentView.backgroundColor = .magenta
            case 0.75...1.00:
                self.contentView.backgroundColor = .green

            default:
                break
        }

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
