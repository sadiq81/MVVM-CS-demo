import Combine
import Foundation

import MustacheUIKit
import MustacheServices

class LoginViewController: UIViewController {

    // MARK: @IBOutlets
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var bodyLabel: UILabel!
    
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var eyeButton: ImageButton!
    
    @IBOutlet weak var forgotButton: UIButton!
    @IBOutlet weak var loginButton: UIButton!

    // MARK: ViewModel

    @Injected
    var viewModel: LoginViewModelType

    @Injected
    var loggingService: LoggingServiceType

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
        self.configureConstraints()
        self.configureBindings()
    }

    // MARK: Configure

    private func configureView() {
        // Set background colors
        self.view.backgroundColor = Colors.Background.default.color
        self.scrollView.backgroundColor = Colors.Background.default.color

#if DEBUG
        self.usernameTextField.text = "th@mustache.dk"
        self.passwordTextField.text = "pickle123"
#endif
        self.passwordTextField.rightView = self.eyeButton
        self.passwordTextField.rightViewMode = .always

        // Title and body with proper hierarchy
        self.titleLabel.configure(textStyle: .title1, text: Strings.Login.title, color: .default)
        self.bodyLabel.configure(textStyle: .body, text: Strings.Login.body, color: .muted)

        self.usernameTextField.configure(textStyle: .body, placeholder: Strings.Login.Textfield.Username.placeholder)
        self.passwordTextField.configure(textStyle: .body, placeholder: Strings.Login.Textfield.Password.placeholder)

        // Forgot is a link, Login is primary CTA
        self.forgotButton.configure(style: .link, text: Strings.Login.Button.Forgot.title)
        self.loginButton.configure(style: .primary, text: Strings.Login.Button.Login.title)
    }
    
    private func configureConstraints() {
        self.constrainKeyboard(to: self.scrollView)
    }

    private func configureBindings() {

        Publishers.CombineLatest(
            self.usernameTextField.textPublisher(),
            self.passwordTextField.textPublisher())
        .debounce(for: .milliseconds(100), scheduler: RunLoop.main)
        .map({ username, password -> CGFloat in
            let enabled = username.count >= 1 && password.count >= 1
            return enabled ? 1 : 0
        })
        .removeDuplicates()
        .sink { [weak self] alpha in
            UIView.animate(withDuration: 0.3) {
                self?.loginButton.alpha = alpha
            }
        }
        .store(in: &self.cancellables)
    }

    // MARK: @IBActions

    @IBAction func editingDidEndOnExit(_ textfield: UITextField) {
        switch textfield {
            case self.usernameTextField:
                self.passwordTextField.becomeFirstResponder()
            case self.passwordTextField:
                guard self.loginButton.alpha == 1 else { return }
                self.login()
            default:
                break

        }
    }

    @IBAction func toggleSecureTextEntry() {
        self.passwordTextField.isSecureTextEntry = !self.passwordTextField.isSecureTextEntry
        self.eyeButton.isSelected = !self.eyeButton.isSelected
    }

    @IBAction func forgotPassword() {
        self.passwordTextField.text = nil
        try? self.coordinator.transition(to: LoginTransition.forgotPassword)
    }

    @IBAction func login() { Task { @MainActor in
        defer { self.loginButton.isBusy = false }
        self.loginButton.isBusy = true
        
        guard
            let username = self.usernameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines),
            username.count > 0
        else {
            self.usernameTextField.superview?.shake()
            return
        }

        guard let password = self.passwordTextField.text, password.count > 0
        else {
            self.passwordTextField.superview?.shake()
            return
        }

        do {
            try await self.viewModel.login(username: username, password: password)
            self.loggingService.log(event: .login(success: true))
            try? self.coordinator.stop()
        } catch {
            self.loggingService.log(event: .login(success: false))
            self.alert(title: Strings.Error.Generic.title, message: Strings.Error.Login.message)
        }
    }}

    // MARK: Override UIViewController functions

    override var preferredStatusBarStyle: UIStatusBarStyle { return .lightContent }

    deinit {
        debugPrint("deinit \(self)")
    }

}

// MARK: Extensions
