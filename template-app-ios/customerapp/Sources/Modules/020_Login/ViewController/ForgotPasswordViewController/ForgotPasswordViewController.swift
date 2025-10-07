import UIKit
import MustacheUIKit

import MustacheFoundation
import MustacheServices
import Combine

class ForgotPasswordViewController: UIViewController {

    // MARK: @IBOutlets
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var bodyLabel: UILabel!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var resetButton: UIButton!

    // MARK: ViewModel

    @Injected
    private var viewModel: ForgotPasswordViewModelType

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

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if self.isMovingToParent {
            self.emailTextField.becomeFirstResponder()
        }
    }

    // MARK: Configure

    private func configureView() {
        let close = UIBarButtonItem(image: UIImage(systemName: "xmark"), style: .plain, target: self, action: #selector(close))
        self.navigationItem.rightBarButtonItem = close

        // Set background colors
        self.view.backgroundColor = Colors.Background.default.color
        self.scrollView.backgroundColor = Colors.Background.default.color

        // Text hierarchy - title default, body muted
        self.titleLabel.configure(textStyle: .title1, text: Strings.ForgotPassword.title, color: .default)
        self.bodyLabel.configure(textStyle: .body, text: Strings.ForgotPassword.body, color: .muted)

        self.emailTextField.configure(textStyle: .body, placeholder: Strings.ForgotPassword.Textfield.placeholder)

        self.resetButton.configure(style: .primary, text: Strings.ForgotPassword.Button.title)
    }
    
    private func configureConstraints() {
        self.constrainKeyboard(to: self.scrollView)
    }
    
    private func configureBindings() {
        
        self.emailTextField.textPublisher()
            .debounce(for: .milliseconds(100), scheduler: RunLoop.main)
            .map({ email -> CGFloat in
                let enabled = email.count >= 1
                return enabled ? 1 : 0
            })
            .removeDuplicates()
            .sink { [weak self] alpha in
                UIView.animate(withDuration: 0.3) {
                    self?.resetButton.alpha = alpha
                }
            }
            .store(in: &self.cancellables)
        
    }
    

    // MARK: @IBActions

    @IBAction func editingDidEndOnExit(_ textfield: UITextField) {
        self.restorePassword(textfield)
    }

    @IBAction func restorePassword(_ sender: Any) { Task {
        defer { self.resetButton.isBusy = false }

        self.emailTextField.resignFirstResponder()

        guard let email = self.emailTextField.text, email.count > 0 else {
            self.emailTextField.superview?.shake()
            return
        }

        do {
            self.resetButton.isBusy = true
            try await self.viewModel.forgotPassword(email: email)
            self.loggingService.log(event: .forgotPassword)
            
            UIAlertController.alert(title: Strings.ForgotPassword.Alert.title)
                .action(title: Strings.Button.ok, handler: { [weak self] _ in self?.close() })
                .present(in: self)
            
        } catch {
            UIAlertController.alert(title: Strings.Error.Generic.title, message: error.localizedDescription)
                .action(title: Strings.Button.ok, handler: { [weak self] _ in self?.close() })
                .present(in: self)
        }

    }}

    @IBAction
    func close() {
        self.dismiss(animated: true)
    }

    // MARK: Override UIViewController functions

}
// MARK: Extensions
