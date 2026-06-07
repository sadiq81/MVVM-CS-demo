import Combine
import Foundation
import UIKit

import MustacheFoundation
import MustacheServices
import MustacheUIKit

@IBDesignable
final class PinView: UIControl, UIKeyInput, UITextInputTraits {

    // MARK: - Properties

    private var pinDigitViews: [PinDigitView] = []
    private let stackView = UIStackView()
    private var cancellables = Set<AnyCancellable>()

    @objc dynamic private(set) var pin: String = "" {
        didSet {
            self.updateDigitViews()
        }
    }

    private let pinLength = 4

    // MARK: - UIKeyInput

    var hasText: Bool {
        return !self.pin.isEmpty
    }

    func insertText(_ text: String) {
        guard self.pin.count < self.pinLength else { return }
        guard text.rangeOfCharacter(from: CharacterSet.decimalDigits.inverted) == nil else { return }

        self.pin.append(text)
        self.sendActions(for: .valueChanged)
    }

    func deleteBackward() {
        guard !self.pin.isEmpty else { return }
        self.pin.removeLast()
        self.sendActions(for: .valueChanged)
    }

    // MARK: - UITextInputTraits

    var keyboardType: UIKeyboardType {
        get { .numberPad }
        set { }
    }

    var autocorrectionType: UITextAutocorrectionType {
        get { .no }
        set { }
    }

    // MARK: - Initialization

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.configureView()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.configureView()
    }

    // MARK: - Configuration

    private func configureView() {
        self.backgroundColor = .clear

        // Configure stack view
        self.stackView.axis = .horizontal
        self.stackView.distribution = .fillEqually
        self.stackView.spacing = Spacing.large
        self.stackView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(self.stackView)

        NSLayoutConstraint.activate([
            self.stackView.topAnchor.constraint(equalTo: self.topAnchor),
            self.stackView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            self.stackView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            self.stackView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            self.stackView.heightAnchor.constraint(equalToConstant: 80)
        ])

        // Create pin digit views
        for _ in 0..<self.pinLength {
            let digitView = PinDigitView()
            self.pinDigitViews.append(digitView)
            self.stackView.addArrangedSubview(digitView)

            let widthConstraint = digitView.widthAnchor.constraint(equalToConstant: 58)
            widthConstraint.priority = .defaultHigh
            let heightConstraint = digitView.heightAnchor.constraint(equalToConstant: 80)
            heightConstraint.priority = .defaultHigh
            
            NSLayoutConstraint.activate([widthConstraint, heightConstraint])
        }

        // Add tap gesture to become first responder
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.handleTap))
        self.addGestureRecognizer(tapGesture)
    }

    // MARK: - Actions

    @objc private func handleTap() {
        let _ = self.becomeFirstResponder()
    }

    // MARK: - Public Methods

    func reset() {
        self.pin = ""
    }

    // MARK: - UIResponder

    override var canBecomeFirstResponder: Bool {
        return true
    }

    override func becomeFirstResponder() -> Bool {
        let result = super.becomeFirstResponder()
        if result {
            self.updateDigitViews()
        }
        return result
    }

    override func resignFirstResponder() -> Bool {
        let result = super.resignFirstResponder()
        if result {
            self.updateDigitViews()
        }
        return result
    }

    // MARK: - Private Methods

    private func updateDigitViews() {
        let currentIndex = self.pin.count

        for (index, digitView) in self.pinDigitViews.enumerated() {
            let digit = self.pin.count > index ? String(self.pin[self.pin.index(self.pin.startIndex, offsetBy: index)]) : nil
            let isFocused = index == currentIndex && self.isFirstResponder

            digitView.configure(digit: digit, isFocused: isFocused)
        }
    }
}

// MARK: - PinDigitView

private final class PinDigitView: UIView {

    private let containerView = UIView()
    private let digitLabel = UILabel()
    private let bulletLabel = UILabel()
    private let caretView = UIView()

    private var currentDigit: String?
    nonisolated(unsafe) private var showDigitTimer: Timer?
    nonisolated(unsafe) private var caretTimer: Timer?

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupView()
    }

    private func setupView() {
        // Container view with rounded corners
        self.containerView.backgroundColor = Colors.Background.neutral.color
        self.containerView.layer.cornerRadius = Constants.Rounding.small
        self.containerView.layer.masksToBounds = true
        self.containerView.layer.borderWidth = 2
        self.containerView.layer.borderColor = UIColor.clear.cgColor
        self.containerView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(self.containerView)

        NSLayoutConstraint.activate([
            self.containerView.topAnchor.constraint(equalTo: self.topAnchor),
            self.containerView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            self.containerView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            self.containerView.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        ])

        // Digit label
        self.digitLabel.textAlignment = .center
        self.digitLabel.font = .preferredFont(forTextStyle: .largeTitle)
        self.digitLabel.textColor = Colors.Foreground.default.color
        self.digitLabel.translatesAutoresizingMaskIntoConstraints = false
        self.containerView.addSubview(self.digitLabel)

        NSLayoutConstraint.activate([
            self.digitLabel.centerXAnchor.constraint(equalTo: self.containerView.centerXAnchor),
            self.digitLabel.centerYAnchor.constraint(equalTo: self.containerView.centerYAnchor)
        ])

        // Bullet label (for secure entry)
        self.bulletLabel.text = "●"
        self.bulletLabel.textAlignment = .center
        self.bulletLabel.font = .preferredFont(forTextStyle: .largeTitle)
        self.bulletLabel.textColor = Colors.Foreground.default.color
        self.bulletLabel.isHidden = true
        self.bulletLabel.translatesAutoresizingMaskIntoConstraints = false
        self.containerView.addSubview(self.bulletLabel)

        NSLayoutConstraint.activate([
            self.bulletLabel.centerXAnchor.constraint(equalTo: self.containerView.centerXAnchor),
            self.bulletLabel.centerYAnchor.constraint(equalTo: self.containerView.centerYAnchor)
        ])

        // Flashing caret
        self.caretView.backgroundColor = Colors.Foreground.default.color
        self.caretView.layer.cornerRadius = 1
        self.caretView.isHidden = true
        self.caretView.translatesAutoresizingMaskIntoConstraints = false
        self.containerView.addSubview(self.caretView)

        NSLayoutConstraint.activate([
            self.caretView.centerXAnchor.constraint(equalTo: self.containerView.centerXAnchor),
            self.caretView.centerYAnchor.constraint(equalTo: self.containerView.centerYAnchor),
            self.caretView.widthAnchor.constraint(equalToConstant: 2),
            self.caretView.heightAnchor.constraint(equalToConstant: 28)
        ])
    }

    func configure(digit: String?, isFocused: Bool) {
        let wasEmpty = self.currentDigit == nil
        let isNowFilled = digit != nil
        let isNewDigit = wasEmpty && isNowFilled

        self.currentDigit = digit

        // Handle border — static border for focused state
        if isFocused {
            self.containerView.layer.borderColor = Colors.Border.default.color.cgColor
        } else {
            self.containerView.layer.borderColor = UIColor.clear.cgColor
        }

        // Handle caret — flashing cursor in focused empty digit
        if isFocused && digit == nil {
            self.startCaretFlashing()
        } else {
            self.stopCaretFlashing()
        }

        // Handle digit display with brief reveal before securing
        if let digit = digit {
            self.digitLabel.text = digit

            if isNewDigit {
                self.bulletLabel.isHidden = true
                self.digitLabel.isHidden = false

                self.showDigitTimer?.invalidate()
                let timer = Timer(timeInterval: 0.1, repeats: false) { [weak self] _ in
                    guard let self else { return }
                    Task { @MainActor in
                        self.digitLabel.isHidden = true
                        self.bulletLabel.isHidden = false
                    }
                }
                self.showDigitTimer = timer
                RunLoop.main.add(timer, forMode: .common)
            } else {
                self.digitLabel.isHidden = true
                self.bulletLabel.isHidden = false
            }
        } else {
            self.showDigitTimer?.invalidate()
            self.digitLabel.text = nil
            self.digitLabel.isHidden = false
            self.bulletLabel.isHidden = true
        }
    }

    private func startCaretFlashing() {
        self.caretView.isHidden = false
        self.caretView.alpha = 1
        self.caretTimer?.invalidate()

        let timer = Timer(timeInterval: 0.5, repeats: true) { [weak self] _ in
            guard let self else { return }
            Task { @MainActor in
                UIView.animate(withDuration: 0.2) {
                    self.caretView.alpha = self.caretView.alpha > 0.5 ? 0 : 1
                }
            }
        }
        self.caretTimer = timer
        RunLoop.main.add(timer, forMode: .common)
    }

    private func stopCaretFlashing() {
        self.caretTimer?.invalidate()
        self.caretTimer = nil
        self.caretView.isHidden = true
        self.caretView.alpha = 1
    }

    deinit {
        self.showDigitTimer?.invalidate()
        self.caretTimer?.invalidate()
    }
}

#if DEBUG
#Preview("PinView") {
    let view = PinView(frame: CGRect(x: 0, y: 0, width: 375, height: 80))
    return view
}
#endif
