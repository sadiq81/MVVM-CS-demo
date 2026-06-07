import Combine
import Foundation
import UIKit

import MustacheServices
import MustacheUIKit

final class MoreViewController: UIViewController {

    // MARK: @IBOutlets

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var contentStackView: UIStackView!

    @IBOutlet weak var settingsHeader: UILabel!
    @IBOutlet weak var settingsRowsContainer: UIView!
    @IBOutlet weak var profileButton: UIButton!
    @IBOutlet weak var feature2Button: UIButton!

    @IBOutlet weak var faceIdHeader: UILabel!
    @IBOutlet weak var faceIdRowsContainer: UIView!
    @IBOutlet weak var secretButton: UIButton!

    @IBOutlet weak var logoutButton: UIButton!

    // MARK: ViewModel

    @Injected(\.userViewModelType)
    private var viewModel: any UserViewModelType

    // MARK: Coordinator

    var coordinator: (any CoordinatorType)!

    // MARK: Cancellable

    private var cancellables = Set<AnyCancellable>()

    // MARK: LifeCycle

    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureView()
        self.configureBindings()
    }

    // MARK: Configure

    private func configureView() {
        self.view.backgroundColor = Colors.Background.default.color
        self.scrollView.backgroundColor = Colors.Background.default.color

        // Section headers
        self.settingsHeader.configure(textStyle: .caption1, text: Strings.More.Caption.settings.uppercased(), color: .muted)
        self.faceIdHeader.configure(textStyle: .caption1, text: Strings.More.Caption.faceId.uppercased(), color: .muted)

        // Rows containers — rounded corners and surface background
        self.settingsRowsContainer.backgroundColor = Colors.Background.surface.color
        self.settingsRowsContainer.layer.cornerRadius = Constants.Rounding.medium
        self.settingsRowsContainer.clipsToBounds = true

        self.faceIdRowsContainer.backgroundColor = Colors.Background.surface.color
        self.faceIdRowsContainer.layer.cornerRadius = Constants.Rounding.medium
        self.faceIdRowsContainer.clipsToBounds = true

        // Row buttons — text and colors set in code
        self.configureRowButton(self.profileButton, title: Strings.More.Label.profile)
        self.configureRowButton(self.feature2Button, title: Strings.More.Label.feature2)
        self.configureRowButton(self.secretButton, title: Strings.More.Label.secret)

        // Logout button
        self.logoutButton.setTitle(Strings.More.Button.logout, for: .normal)
        self.logoutButton.setTitleColor(Colors.Foreground.danger.color, for: .normal)
        self.logoutButton.titleLabel?.font = UIFont.preferredFont(forTextStyle: .body)
        self.logoutButton.backgroundColor = Colors.Background.surface.color
        self.logoutButton.layer.cornerRadius = Constants.Rounding.medium
        self.logoutButton.clipsToBounds = true
    }

    private func configureRowButton(_ button: UIButton, title: String) {
        button.setTitle(title, for: .normal)
        button.setTitleColor(Colors.Foreground.default.color, for: .normal)
        button.titleLabel?.font = UIFont.preferredFont(forTextStyle: .body)
        button.contentHorizontalAlignment = .leading
        button.contentEdgeInsets = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
    }

    private func configureBindings() {
        self.viewModel.featureFlagsPublisher
            .receive(on: RunLoop.main)
            .sink { [weak self] featureFlags in
                self?.feature2Button.isHidden = !featureFlags.contains(.feature2)
            }
            .store(in: &self.cancellables)
    }

    // MARK: @IBActions

    @IBAction func profileTapped() {
        try? self.coordinator.transition(to: MoreTransition.profile)
    }

    @IBAction func feature2Tapped() {
        guard let url = URL(string: "https://www.claude.ai") else { return }
        try? self.coordinator.transition(to: MoreTransition.webview(url: url))
    }

    @IBAction func secureContentTapped() {
        try? self.coordinator.transition(to: MoreTransition.secureContent)
    }

    @IBAction func logoutTapped() {
        let alertController = UIAlertController(title: Strings.Alert.LogOut.title,
                                                message: Strings.Alert.LogOut.message,
                                                preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: Strings.Alert.LogOut.cancel, style: .cancel, handler: nil))
        alertController.addAction(UIAlertAction(title: Strings.Alert.LogOut.accept, style: .destructive, handler: { [weak self] _ in
            self?.viewModel.logOut()
            try? self?.coordinator.transition(to: AppTransition.login)
        }))

        self.present(alertController, animated: true, completion: nil)
    }

    // MARK: Override UIViewController functions

    override var preferredStatusBarStyle: UIStatusBarStyle { return .lightContent }

    deinit {
        debugPrint("deinit \(self)")
    }

}

// MARK: - Preview

#if DEBUG
#Preview("MoreViewController") {
    Container.shared.userViewModelType.register { MainActor.assumeIsolated { PreviewUserViewModel() } }

    let viewController = AppStoryboard.viewController(class: MoreViewController.self)
    viewController.coordinator = UIKitPreviewCoordinator()
    return UINavigationController(rootViewController: viewController)
}
#endif
