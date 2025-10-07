import Foundation

import MustacheCombine
import MustacheServices
import MustacheUIKit

class PasswordViewController: UIViewController {
    
    // MARK: @IBOutlets
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var containerView: UIView!
    
    @IBOutlet weak var oldPasswordCaptionLabel: UILabel!
    @IBOutlet weak var oldPasswordTextField: UITextField!
    
    @IBOutlet weak var passwordCaptionLabel: UILabel!
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var repeatPasswordCaptionLabel: UILabel!
    @IBOutlet weak var repeatPasswordTextField: UITextField!
    
    @IBOutlet weak var saveButton: UIButton!
    
    // MARK: ViewModel
    
    @Injected
    private var viewModel: UserViewModelType
    
    // MARK: Coordinator
    
    var coordinator: CoordinatorType!
    
    // MARK: Cancellable
    
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: UI State Variables (Avoid if possible)
    
    // MARK: View lifecyle
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
        self.scrollView.backgroundColor = .clear

        // Caption labels with muted color
        self.oldPasswordCaptionLabel.configure(textStyle: .caption2, text: Strings.Password.Caption.oldPassword, color: .muted)
        self.oldPasswordTextField.configure(textStyle: .body, placeholder: Strings.Password.Textfield.Placeholder.oldPassword)

        self.passwordCaptionLabel.configure(textStyle: .caption2, text: Strings.Password.Caption.password, color: .muted)
        self.passwordTextField.configure(textStyle: .body, placeholder: Strings.Password.Textfield.Placeholder.password)

        self.repeatPasswordCaptionLabel.configure(textStyle: .caption2, text: Strings.Password.Caption.repeatPassword, color: .muted)
        self.repeatPasswordTextField.configure(textStyle: .body, placeholder: Strings.Password.Textfield.Placeholder.repeatPassword)

        self.saveButton.configure(style: .primary, text: Strings.Password.Button.save)
    }
    
    private func configureConstraints() {
        self.constrainKeyboard(to: self.scrollView)        
    }
    
    private func configureBindings() {
        Publishers.CombineLatest3(
            self.oldPasswordTextField.textPublisher(),
            self.passwordTextField.textPublisher(),
            self.repeatPasswordTextField.textPublisher()
        )
        .map { oldPassword, password, repeatPassword -> Int in
            let valid = (oldPassword.hasElements &&
                         password == repeatPassword &&
                         password.count >= 6)
            return valid ? 1 : 0
        }
        .removeDuplicates()
        .sink { [weak self] (alpha: Int) in
            UIView.animate(withDuration: 0.3) { self?.saveButton.alpha = CGFloat(alpha) }
        }
        .store(in: &self.cancellables)
        
    }
    
    // MARK: @IBActions
    
    @IBAction func save() { Task {
        defer { self.saveButton.isBusy = false }
        
        guard
            let oldPassword = self.oldPasswordTextField.text,
            let password = self.passwordTextField.text,
            let repeatPassword = self.repeatPasswordTextField.text
        else { return }
        
        do {
            self.saveButton.isBusy = true
            try await self.viewModel.update(oldPassword: oldPassword, password: password, repeatPassword: repeatPassword)
        } catch {
            self.alert(error: error)
        }
        
    }}
    
    @IBAction func editingDidEndOnExit(_ textfield: UITextField) {
        switch textfield {
                
            case self.oldPasswordTextField:
                self.passwordTextField.becomeFirstResponder()
            case self.passwordTextField:
                self.repeatPasswordTextField.becomeFirstResponder()
            default:
                break
        }
    }
    
    // MARK: Override UIViewController functions
    
    override var preferredStatusBarStyle: UIStatusBarStyle { return .lightContent }
    
    deinit {
        debugPrint("deinit \(self)")
    }
    
}

// MARK: Extensions
