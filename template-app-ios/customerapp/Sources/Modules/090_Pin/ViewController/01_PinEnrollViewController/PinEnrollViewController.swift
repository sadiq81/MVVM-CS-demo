import Combine
import Foundation

import MustacheServices
import MustacheUIKit

class PinEnrollViewController: BackgroundDimmingViewController {

    // MARK: @IBOutlets
    @IBOutlet weak var panelView: UIView!
    @IBOutlet weak var stackViewBottomConstraints: NSLayoutConstraint!

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var bodyLabel: UILabel!
    
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
        _ = self.pinView.becomeFirstResponder()
    }

    // MARK: Configure

    private func configure() {
        // Set background colors
        self.view.backgroundColor = Colors.Background.default.color
        self.panelView.backgroundColor = Colors.Background.surface.color
        self.scrollView.backgroundColor = .clear

        // Text hierarchy
        self.titleLabel.configure(textStyle: .title1, text: Strings.Pin.Enroll.title, color: .default)
        self.bodyLabel.configure(textStyle: .body, text: Strings.Pin.Enroll.body, color: .muted)

        self.submitButton.configure(style: .primary, text: Strings.Pin.Enroll.Button.submit)

        self.pinLoading.configurePinLoadingIndicator()
    }
    
    private func configureConstraints() {}
    
    private func configureBindings() {

        // When first pin is entered (4 digits), scroll to repeat pin
        self.pinView.publisher(for: \.pin)
            .sink { [weak self] pin in
                guard let self = self else { return }
                if pin.count == 4 {
                    let _ = self.pinView.resignFirstResponder()

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
                    let _ = self.pinRepeatView.resignFirstResponder()

                    UIView.animate(
                        withDuration: 0.3,
                        animations: {
                            self.scrollView.contentOffset = .zero
                        },
                        completion: { _ in
                            let _ =  self.pinView.becomeFirstResponder()
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
        self.dismiss(animated: true, completion: { [weak self] in
                try? self?.coordinator.stop()
            })
    }

    @IBAction func submitButtonPressed(_ sender: Any) {
        Task {

            defer { self.submitButton.isBusy = false }

            let pin = self.pinView.pin
            let repeatPin = self.pinRepeatView.pin

            guard pin.count == 4, pin == repeatPin else {
                UIAlertController.alert(title: Strings.Error.Generic.title, message: Strings.Alert.Pin.NotMatching.message)
                    .action(title: Strings.Button.ok, handler: { [weak self] _ in self?.resetScrollAndPinViews() })
                    .present(in: self)
                return
            }
            
            do {
                self.submitButton.isBusy = true
                try await self.viewModel.store(pin: pin)

                // Ask user if they want to use biometrics
                let title = self.viewModel.biometricType == .faceID ? Strings.Alert.Pin.FaceId.title : Strings.Alert.Pin.TouchId.title
                let message = self.viewModel.biometricType == .faceID ? Strings.Alert.Pin.FaceId.message : Strings.Alert.Pin.TouchId.message
                
                UIAlertController.alert(title: title, message: message)
                    .action(title: Strings.Button.ok, handler: { [weak self] _ in self?.storeWithBiometric() })
                    .action(title: Strings.Button.cancel, handler: { [weak self] _ in self?.didEnroll() })
                    .present(in: self)
                
            } catch {
                
                UIAlertController.alert(title: Strings.Error.Generic.title, message:  error.localizedDescription)
                    .action(title: Strings.Button.ok, handler: { [weak self] _ in self?.resetScrollAndPinViews() })
                    .present(in: self)
            }

        }
    }
    
    private func storeWithBiometric() { Task {
        try? await self.viewModel.storeWithBiometric()
        self.didEnroll()
    }}


    private func didEnroll() { Task { @MainActor in

        self.pinRepeatView.alpha = 0
        self.pinLoading.alpha = 1

        // Show success animation
        try await self.pinLoading.showPinSuccessAnimation()

        self.stackViewBottomConstraints.isActive = false
        self.dismiss(animated: true, completion: {
            self.delegate?.didEnroll(data: self.viewModel.data!)
        })
    }}

    private func resetScrollAndPinViews() {
        self.pinView.reset()
        self.pinRepeatView.reset()
        self.scrollView.setContentOffset(.zero, animated: true)
        _ = self.pinView.becomeFirstResponder()

        // Reset loading indicator
        self.pinLoading.alpha = 0
        self.pinLoading.resetPinLoadingIndicator()
    }

    // MARK: Override UIViewController functions

    deinit { debugPrint("deinit: \(self)") }
}

// MARK: Extensions
