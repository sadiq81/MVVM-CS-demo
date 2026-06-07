import Combine
import UIKit

import MustacheCombine
import MustacheFoundation
import MustacheServices
import MustacheUIKit

final class SignupViewController: UIViewController {

    // MARK: @IBOutlets
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var bodyLabel: UILabel!

    @IBOutlet weak var fullNameContainerView: UIView!
    @IBOutlet weak var fullNameTextField: UITextField!
    @IBOutlet weak var emailContainerView: UIView!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordContainerView: UIView!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var confirmPasswordContainerView: UIView!
    @IBOutlet weak var confirmPasswordTextField: UITextField!

    @IBOutlet weak var signupButton: UIButton!

    // MARK: ViewModel

    @Injected(\.signupViewModel)
    private var viewModel: any SignupViewModelType

    @Injected(\.loggingService)
    var loggingService: any LoggingServiceType

    // MARK: Coordinator

    var coordinator: (any CoordinatorType)!

    // MARK: Cancellable

    private var cancellables = Set<AnyCancellable>()

    // MARK: LifeCycle

    override func viewDidLoad() {
        super.viewDidLoad()

        self.configureView()
        self.configureConstraints()
        self.configureBindings()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if self.isMovingToParent {
            self.fullNameTextField.becomeFirstResponder()
        }
    }

    // MARK: Configure

    private func configureView() {
        let close = UIBarButtonItem(image: UIImage(systemName: Images.System.close), style: .plain, target: self, action: #selector(close))
        self.navigationItem.rightBarButtonItem = close

        // Backgrounds
        self.view.backgroundColor = Colors.Background.default.color
        self.scrollView.backgroundColor = Colors.Background.default.color

        for container in [self.fullNameContainerView, self.emailContainerView, self.passwordContainerView, self.confirmPasswordContainerView] {
            container?.backgroundColor = Colors.Background.neutralSubtle.color
            container?.layer.cornerRadius = Constants.Rounding.small
        }

        // Text hierarchy
        self.titleLabel.configure(textStyle: .title1, text: Strings.Signup.title, color: .default)
        self.bodyLabel.configure(textStyle: .body, text: Strings.Signup.body, color: .muted)

        self.fullNameTextField.configure(textStyle: .body, placeholder: Strings.Signup.Textfield.Fullname.placeholder)
        self.emailTextField.configure(textStyle: .body, placeholder: Strings.Signup.Textfield.Email.placeholder)
        self.passwordTextField.configure(textStyle: .body, placeholder: Strings.Signup.Textfield.Password.placeholder)
        self.passwordTextField.isSecureTextEntry = true
        self.confirmPasswordTextField.configure(textStyle: .body, placeholder: Strings.Signup.Textfield.Confirmpassword.placeholder)
        self.confirmPasswordTextField.isSecureTextEntry = true

        self.signupButton.configure(style: .primary, text: Strings.Signup.Button.Signup.title)
    }

    private func configureConstraints() {
        self.constrainKeyboard(to: self.scrollView)
    }

    private func configureBindings() {

        Publishers.CombineLatest4(
            self.fullNameTextField.textPublisher(),
            self.emailTextField.textPublisher(),
            self.passwordTextField.textPublisher(),
            self.confirmPasswordTextField.textPublisher())
        .debounce(for: .milliseconds(100), scheduler: RunLoop.main)
        .map({ fullName, email, password, confirm -> CGFloat in
            let enabled = !fullName.isEmpty && !email.isEmpty && password.count >= 8 && password == confirm
            return enabled ? 1 : 0
        })
        .removeDuplicates()
        .sink { [weak self] alpha in
            UIView.animate(withDuration: 0.3) {
                self?.signupButton.alpha = alpha
            }
        }
        .store(in: &self.cancellables)
    }

    // MARK: @IBActions

    @IBAction func editingDidEndOnExit(_ textfield: UITextField) {
        switch textfield {
            case self.fullNameTextField:
                self.emailTextField.becomeFirstResponder()
            case self.emailTextField:
                self.passwordTextField.becomeFirstResponder()
            case self.passwordTextField:
                self.confirmPasswordTextField.becomeFirstResponder()
            default:
                guard self.signupButton.alpha == 1 else { return }
                self.signup()
        }
    }

    @IBAction func signup() { Task { @MainActor in
        defer { self.signupButton.isBusy = false }

        guard let fullName = self.fullNameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines), !fullName.isEmpty else {
            self.fullNameTextField.superview?.shake(); return
        }
        guard let email = self.emailTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines), !email.isEmpty else {
            self.emailTextField.superview?.shake(); return
        }
        guard let password = self.passwordTextField.text, !password.isEmpty else {
            self.passwordTextField.superview?.shake(); return
        }
        guard let confirm = self.confirmPasswordTextField.text, password == confirm else {
            self.confirmPasswordTextField.superview?.shake(); return
        }

        do {
            self.signupButton.isBusy = true
            try await self.viewModel.signup(fullName: fullName, email: email, password: password, confirmPassword: confirm)
            self.loggingService.log(event: .login(success: true))
            try? self.coordinator.stop()
        } catch {
            self.loggingService.log(event: .login(success: false))
            self.alert(title: Strings.Error.Generic.title, message: error.localizedDescription)
        }
    }}

    @IBAction
    func close() {
        self.dismiss(animated: true)
    }

    // MARK: Override UIViewController functions

    override var preferredStatusBarStyle: UIStatusBarStyle { return .lightContent }

    deinit {
        debugPrint("deinit \(self)")
    }

}

// MARK: Extensions

#if DEBUG
#Preview("SignupViewController") {
    Container.shared.signupViewModel.register { PreviewSignupViewModel() }
    Container.shared.loggingService.register { PreviewLoggingService() }

    let viewController = AppStoryboard.viewController(class: SignupViewController.self)
    viewController.coordinator = UIKitPreviewCoordinator()
    return UINavigationController(rootViewController: viewController)
}
#endif
