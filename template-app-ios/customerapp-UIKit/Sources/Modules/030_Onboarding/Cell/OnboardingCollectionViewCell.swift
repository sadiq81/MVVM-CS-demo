import UIKit

final class OnboardingCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var bodyLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!

    func configure(with step: OnboardingStep) {
        // Title with default color, body with muted for hierarchy
        self.titleLabel.configure(textStyle: .title1, text: step.title, color: .default)
        self.bodyLabel.configure(textStyle: .body, text: step.body, color: .muted)

        let configuration = UIImage.SymbolConfiguration(pointSize: 64)
        self.imageView.image = UIImage(systemName: step.image, withConfiguration: configuration)
        self.imageView.contentMode = .center
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        MainActor.assumeIsolated { self.configureCell() }
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
            case .camera: return Strings.Onboarding.Step3.body
        }
    }

    var image: String {
        switch self {
            case .location: return Images.System.locationBadge
            case .notification: return Images.System.messageBadgeFill
            case .camera: return Images.System.cameraFill
        }
    }

}

#if DEBUG
#Preview("OnboardingCollectionViewCell") {
    let nib = UINib(nibName: "OnboardingCollectionViewCell", bundle: .main)
    let cell = nib.instantiate(withOwner: nil).first as! OnboardingCollectionViewCell
    cell.frame = CGRect(x: 0, y: 0, width: 375, height: 400)
    cell.configure(with: OnboardingStep.mockData)
    return cell
}
#endif
