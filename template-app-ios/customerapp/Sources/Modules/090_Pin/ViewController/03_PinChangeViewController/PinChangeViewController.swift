import Combine
import Foundation

import MustacheUIKit
import MustacheServices

class PinChangeViewController: BackgroundDimmingViewController {
    
    // MARK: @IBOutlets
    @IBOutlet weak var panelView: UIView!
    @IBOutlet weak var stackViewBottomConstraints: NSLayoutConstraint!
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var bodyLabel: UILabel!
    @IBOutlet weak var bodyRepeatLabel: UILabel!
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var pinView: PinView!
    @IBOutlet weak var pinRepeatView: PinView!
    @IBOutlet weak var pinLoading: UIImageView!
    
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
        self.configureConstraints()
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
        self.scrollView.backgroundColor = .clear

        // Text hierarchy
        self.titleLabel.configure(textStyle: .title1, text: Strings.Pin.Change.title, color: .default)
        self.bodyLabel.configure(textStyle: .body, text: Strings.Pin.Change.body, color: .muted)
        self.bodyRepeatLabel.configure(textStyle: .body, text: Strings.Pin.Change.bodyRepeat, color: .muted)
        self.submitButton.configure(style: .primary, text: Strings.Pin.Change.Button.submit)

        self.pinLoading.configurePinLoadingIndicator()
    }
    
    private func configureConstraints() {
        self.constrainKeyboard(to: self.panelView)
    }

    private func configureBindings() {

        // When first pin is entered (4 digits), scroll to repeat pin
        self.pinView.publisher(for: \.pin)
            .sink { [weak self] pin in
                guard let self = self else { return }
                if pin.count == 4 {
                    UIView.animate(
                        withDuration: 0.3,
                        animations: {
                            self.scrollView.contentOffset = CGPoint(x: self.scrollView.frame.width, y: 0)
                        },
                        completion: { _ in
                            let _ = self.pinRepeatView.becomeFirstResponder()
                        })
                }
            }
            .store(in: &self.cancellables)

        // If we delete in repeat pin when empty, go back to the first pin
        self.pinRepeatView.publisher(for: \.pin)
            .sink { [weak self] pin in
                guard let self = self else { return }
                if pin.isEmpty && !self.pinView.pin.isEmpty {
                    UIView.animate(
                        withDuration: 0.3,
                        animations: {
                            self.scrollView.contentOffset = .zero
                        },
                        completion: { _ in
                            let _ = self.pinView.becomeFirstResponder()
                        })
                }
            }
            .store(in: &self.cancellables)

        // When second pin is entered (4 digits), auto-submit
        self.pinRepeatView.publisher(for: \.pin)
            .sink { [weak self] pin in
                guard let self = self else { return }
                if pin.count == 4 {
                    self.submitButtonPressed(self)
                }
            }
            .store(in: &self.cancellables)

    }

    // MARK: @IBActions

    @IBAction func closeButtonPressed() {
        self.stackViewBottomConstraints.isActive = false
        self.presentingViewController?.dismiss(animated: true)
    }

    @IBAction func submitButtonPressed(_ sender: Any) {
        Task {

            defer { self.submitButton.isBusy = false }

            let pin = self.pinView.pin
            let repeatPin = self.pinRepeatView.pin

            guard pin.count == 4, pin == repeatPin else {

                UIAlertController.alert(title: Strings.Error.Generic.title, message: Strings.Alert.Pin.NotMatching.message)
                    .action(title: Strings.Button.ok, handler: { [weak self] _ in self?.reset() })
                    .present(in: self)
                return
            }
            do {
                self.submitButton.isBusy = true
                try await self.viewModel.update(pin: pin)

                self.pinRepeatView.alpha = 0
                self.pinLoading.alpha = 1

                // Show success animation
                try await self.pinLoading.showPinSuccessAnimation()
                
                self.stackViewBottomConstraints.isActive = false
                self.dismiss(animated: true, completion: {
                    self.delegate?.didChangePin()
                })

            } catch {
                
                UIAlertController.alert(title: Strings.Error.Generic.title, message:  error.localizedDescription)
                    .action(title: Strings.Button.ok, handler: { [weak self] _ in self?.reset() })
                    .present(in: self)
                
            }

        }
    }


    private func reset() {

        self.pinLoading.alpha = 0
        self.pinRepeatView.alpha = 1

        self.pinView.reset()
        self.pinRepeatView.reset()
        self.scrollView.setContentOffset(.zero, animated: true)
        _ = self.pinView.becomeFirstResponder()

        // Reset loading indicator
        self.pinLoading.resetPinLoadingIndicator()
    }

    // MARK: Override UIViewController functions

    deinit { debugPrint("deinit: \(self)") }
}

// MARK: Extensions

