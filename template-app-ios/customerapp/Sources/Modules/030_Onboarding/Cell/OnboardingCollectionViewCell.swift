import UIKit

class OnboardingCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var bodyLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!

    func configure(with step: OnboardingStep) {
        // Title with default color, body with muted for hierarchy
        self.titleLabel.configure(textStyle: .title1, text: step.title, color: .default)
        self.bodyLabel.configure(textStyle: .body, text: step.body, color: .muted)
        self.imageView.image = UIImage(systemName: step.image)
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        self.configureCell()
    }

    private func configureCell() {
        // Brand color for icon to make it stand out
        self.imageView.tintColor = Colors.Foreground.brand.color
    }
}

extension OnboardingStep {

    var title: String {
        switch self {
            case .location: return Strings.Onboarding.Step1.title
            case .notification: return Strings.Onboarding.Step2.title
            case .camera: return Strings.Onboarding.Step3.title
        }
    }

    var body: String {
        switch self {
            case .location: return Strings.Onboarding.Step1.body
            case .notification: return Strings.Onboarding.Step2.body
            case .camera: return Strings.Onboarding.Step2.body
        }
    }

    var image: String {
        switch self {
            case .location: return "iphone.gen3.badge.location"
            case .notification: return "message.badge.filled.fill"
            case .camera: return "camera.fill"
        }     
    }

}
