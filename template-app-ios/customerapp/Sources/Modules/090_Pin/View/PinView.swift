import Foundation
import UIKit
import Combine

import MustacheFoundation
import MustacheUIKit
import MustacheServices

@IBDesignable
class PinView: UIControl, UIKeyInput, UITextInputTraits {

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
        sendActions(for: .valueChanged)
    }

    func deleteBackward() {
        guard !self.pin.isEmpty else { return }
        self.pin.removeLast()
        sendActions(for: .valueChanged)
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
        backgroundColor = .clear

        // Configure stack view
        self.stackView.axis = .horizontal
        self.stackView.distribution = .fillEqually
        self.stackView.spacing = Spacing.Scale.lg
        self.stackView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(self.stackView)

        NSLayoutConstraint.activate([
            self.stackView.topAnchor.constraint(equalTo: topAnchor),
            self.stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            self.stackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            self.stackView.bottomAnchor.constraint(equalTo: bottomAnchor),
            self.stackView.heightAnchor.constraint(equalToConstant: 80)
        ])

        // Create pin digit views
        for _ in 0..<pinLength {
            let digitView = PinDigitView()
            self.pinDigitViews.append(digitView)
            stackView.addArrangedSubview(digitView)

            let widthConstraint = digitView.widthAnchor.constraint(equalToConstant: 58)
            widthConstraint.priority = .defaultHigh
            let heightConstraint = digitView.heightAnchor.constraint(equalToConstant: 80)
            heightConstraint.priority = .defaultHigh
            
            NSLayoutConstraint.activate([widthConstraint, heightConstraint])
        }

        // Add tap gesture to become first responder
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        addGestureRecognizer(tapGesture)
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
        let currentIndex = pin.count

        for (index, digitView) in pinDigitViews.enumerated() {
            let digit = pin.count > index ? String(pin[pin.index(pin.startIndex, offsetBy: index)]) : nil
            let isFocused = index == currentIndex && isFirstResponder

            digitView.configure(digit: digit, isFocused: isFocused)
        }
    }
}

// MARK: - PinDigitView

private class PinDigitView: UIView {

    private let containerView = UIView()
    private let digitLabel = UILabel()
    private let bulletLabel = UILabel()
    private var borderLayer: CAShapeLayer?
    private var flashingAnimation: CAAnimation?

    private var currentDigit: String?
    private var showDigitTimer: Timer?

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
        addSubview(self.containerView)

        NSLayoutConstraint.activate([
            self.containerView.topAnchor.constraint(equalTo: topAnchor),
            self.containerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            self.containerView.trailingAnchor.constraint(equalTo: trailingAnchor),
            self.containerView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])

        // Digit label
        self.digitLabel.textAlignment = .center
        self.digitLabel.font = .preferredFont(forTextStyle: .largeTitle)
        self.digitLabel.textColor = Colors.Foreground.default.color
        self.digitLabel.translatesAutoresizingMaskIntoConstraints = false
        self.containerView.addSubview(self.digitLabel)

        NSLayoutConstraint.activate([
            self.digitLabel.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            self.digitLabel.centerYAnchor.constraint(equalTo: containerView.centerYAnchor)
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
    }

    func configure(digit: String?, isFocused: Bool) {
        let wasEmpty = currentDigit == nil
        let isNowFilled = digit != nil
        let isNewDigit = wasEmpty && isNowFilled

        self.currentDigit = digit

        // Handle border and focus state
        self.stopFlashingBorder()

        if isFocused {
            self.containerView.layer.borderColor = Colors.Border.default.color.cgColor
            self.startFlashingBorder()
        } else {
            self.containerView.layer.borderColor = UIColor.clear.cgColor
        }

        // Handle digit display with brief reveal before securing
        if let digit = digit {
            self.digitLabel.text = digit

            // Only show digit briefly if it's a newly entered digit
            if isNewDigit {
                self.bulletLabel.isHidden = true
                self.digitLabel.isHidden = false

                // Show digit briefly before hiding with bullet
                self.showDigitTimer?.invalidate()
                self.showDigitTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: false) { [weak self] _ in
                    self?.digitLabel.isHidden = true
                    self?.bulletLabel.isHidden = false
                }
            } else {
                // Digit already existed, keep it hidden with bullet showing
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

    private func startFlashingBorder() {
        let animation = CABasicAnimation(keyPath: "borderColor")
        animation.fromValue = Colors.Border.default.color.cgColor
        animation.toValue = UIColor.clear.cgColor
        animation.duration = 0.5
        animation.autoreverses = true
        animation.repeatCount = .infinity
        self.containerView.layer.add(animation, forKey: "borderFlashing")
    }

    private func stopFlashingBorder() {
        self.containerView.layer.removeAnimation(forKey: "borderFlashing")
    }

    deinit {
        self.showDigitTimer?.invalidate()
    }
}
