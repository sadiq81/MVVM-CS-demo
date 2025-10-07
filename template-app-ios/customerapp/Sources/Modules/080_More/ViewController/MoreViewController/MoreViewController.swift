import Foundation
import Combine

import MustacheServices
import MustacheUIKit

class MoreViewController: UIViewController {

    // MARK: @IBOutlets

    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var settingsCaptionLabel: UILabel!
    @IBOutlet weak var profileLabel: UILabel!
    @IBOutlet weak var feature2Label: UILabel!
    
    @IBOutlet weak var faceIdCaptionLabel: UILabel!
    @IBOutlet weak var secretLabel: UILabel!
    
    @IBOutlet weak var feature2ContainerView: UIView!
    @IBOutlet weak var logoutButton: UIButton!

    // MARK: ViewModel

    @Injected
    var viewModel: UserViewModelType

    // MARK: Coordinator

    var coordinator: CoordinatorType!

    // MARK: Delegate

    // MARK: Cancellable

    private var cancellables = Set<AnyCancellable>()

    // MARK: UI State Variables (Avoid if possible)

    // MARK: LifeCycle

    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureView()
        self.configureBindings()
    }

    // MARK: Configure

    private func configureView() {
        // Set background color
        view.backgroundColor = Colors.Background.default.color
        scrollView.backgroundColor = Colors.Background.default.color

        // Section headers - use muted color for captions
        self.settingsCaptionLabel.configure(textStyle: .caption1, text: Strings.More.Caption.settings.uppercased(), color: .muted)
        self.faceIdCaptionLabel.configure(textStyle: .caption1, text: Strings.More.Caption.faceId.uppercased(), color: .muted)

        // Menu items - use default color for labels
        self.profileLabel.configure(textStyle: .body, text: Strings.More.Label.profile, color: .default)
        self.feature2Label.configure(textStyle: .body, text: Strings.More.Label.feature2, color: .default)
        self.secretLabel.configure(textStyle: .body, text: Strings.More.Label.secret, color: .default)

        // Logout button - use destructive style (secondary with red tint)
        self.logoutButton.configure(style: .secondary, text: Strings.More.Button.logout)
    }

    private func configureBindings() {

        self.viewModel.featureFlagsPublisher
            .map({ !$0.contains(.feature2) })
            .sink(receiveValue: { [weak self] isFeature2Disabled in
                self?.feature2ContainerView.isHidden = isFeature2Disabled
            })
            .store(in: &self.cancellables)

    }

    // MARK: @IBActions

    @IBAction func profile() {
        try? self.coordinator.transition(to: MoreTransition.profile)
    }

    @IBAction func feature2() {
        guard let url = URL(string: "https://www.claude.ai") else { return }
        try? self.coordinator.transition(to: MoreTransition.webview(url: url))
    }

    @IBAction func secureContent() {
        try? self.coordinator.transition(to: MoreTransition.secureContent)
    }

    @IBAction func logout() {
        
        let alertController = UIAlertController(title: Strings.Alert.LogOut.title,
                                                message: Strings.Alert.LogOut.message,
                                                preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: Strings.Alert.LogOut.cancel, style: .cancel, handler: nil))
        alertController.addAction(UIAlertAction(title: Strings.Alert.LogOut.accept, style: .destructive, handler: { [weak self] _ in
            self?.logoutButton.isBusy = true
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
// MARK: Extensions
