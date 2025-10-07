import Combine

import MustacheFoundation
import MustacheServices
import MustacheUIKit

class PinValidationViewController: BackgroundDimmingViewController {
    
    // MARK: @IBOutlets
    @IBOutlet weak var panelView: UIView!
    @IBOutlet weak var stackViewBottomConstraints: NSLayoutConstraint!
    
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var pinView: PinView!
    @IBOutlet weak var pinLoading: UIImageView!
    
    @IBOutlet weak var resetButton: UIButton!
    @IBOutlet weak var submitButton: UIButton!
    
    // MARK: ViewModel
    
    @Injected
    var viewModel: PinViewModelType
    
    // MARK: Coordinator
    
    var coordinator: CoordinatorType!
    
    // MARK: Delegate
    
    weak var delegate: PinDelegate?
    
    // MARK: Cancellable
    
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: UI State Variables (Avoid if possible)
    
    // MARK: LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configure()
        //        self.configureConstraints()
        self.configureBindings()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let _ = self.pinView.becomeFirstResponder()
    }
    
    // MARK: Configure
    
    private func configure() {
        // Set background colors
        self.view.backgroundColor = Colors.Background.default.color
        self.panelView.backgroundColor = Colors.Background.surface.color

        // Text hierarchy
        self.titleLabel.configure(textStyle: .title1, text: Strings.Pin.Validation.title, color: .default)
        self.resetButton.configure(style: .link, text: Strings.Pin.Validation.Button.forgot)
        self.submitButton.configure(style: .primary, text: Strings.Pin.Validation.Button.submit)

        self.pinLoading.configurePinLoadingIndicator()
    }
    
    private func configureBindings() {
        
        NotificationCenter.default.publisher(for: .logOut)
            .sink(receiveValue: { [weak self] _ in
                self?.presentingViewController?.dismiss(animated: true)
            })
            .store(in: &self.cancellables)
        
        // Auto-submit when 4 digits are entered
        self.pinView.publisher(for: \.pin)
            .sink { [weak self] pin in
                guard let self else { return }
                if pin.count == 4 {
                    self.submitButtonPressed(self)
                }
            }
            .store(in: &self.cancellables)
        
    }
    
    // MARK: @IBActions
    
    @IBAction func closeButtonPressed() {
        self.stackViewBottomConstraints.isActive = false
        self.dismiss(animated: true) { [weak self] in
            self?.delegate?.didCancel()
        }
        
    }
    
    @IBAction func submitButtonPressed(_ sender: Any) {
        Task { 
            
            let pin = self.pinView.pin
            guard pin.count == 4 else { return }
            
            do {
                // Show loading animation
                self.pinView.alpha = 0
                self.pinLoading.alpha = 1
                self.pinLoading.startPinLoadingAnimation()
                
                let data = try await self.viewModel.validate(pin: pin)
                
                // Show success animation
                try await self.pinLoading.showPinSuccessAnimation()
                
                self.stackViewBottomConstraints.isActive = false
                self.dismiss(animated: true, completion: {
                    self.delegate?.didAuthenticate(data: data)
                })
                
            } catch {
                UIAlertController.alert(title: Strings.Error.Generic.title, message:  error.localizedDescription)
                    .action(title: Strings.Button.ok, handler: { [weak self] _ in self?.reset() })
                    .present(in: self)
            }
        }
    }
    
    @IBAction func resetButtonPressed(_ sender: Any) {
        let _ = self.pinView.resignFirstResponder()
        UIAlertController.alert(title: Strings.Alert.Pin.Reset.title, message:  Strings.Alert.Pin.Reset.message)
            .action(title: Strings.Button.ok, handler: { [weak self] _ in self?.viewModel.reset()  })
            .action(title: Strings.Button.cancel)
            .present(in: self)
    }
    
    private func reset() {
        self.pinView.reset()
        self.pinLoading.alpha = 0
        self.pinLoading.resetPinLoadingIndicator()
    }
    
    // MARK: Override UIViewController functions
    
    deinit { debugPrint("deinit: \(self)") }
}

// MARK: Extensions
