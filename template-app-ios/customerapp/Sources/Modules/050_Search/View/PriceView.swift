import UIKit

@IBDesignable
class PriceView: UIView {

    let integerLabel = UILabel()
    let decimalLabel = UILabel()

    var price: Double = 0.0 {
        didSet {
            self.updateLabels()
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.configure()
        self.configureConstraints()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.configure()
        self.configureConstraints()
    }

    func configure() {

        let font = UIFont.preferredFont(forTextStyle: .title1)

        self.integerLabel.textAlignment = .right
        self.integerLabel.font = font
        self.integerLabel.textColor = Colors.Foreground.default.color
        self.integerLabel.translatesAutoresizingMaskIntoConstraints = false

        self.decimalLabel.textAlignment = .left
        self.decimalLabel.font = font.withSize(font.pointSize / 3)
        self.decimalLabel.textColor = Colors.Foreground.default.color
        self.decimalLabel.translatesAutoresizingMaskIntoConstraints = false

        self.addSubview(self.decimalLabel)
        self.addSubview(self.integerLabel)
    }

    func configureConstraints() {

        self.integerLabel.setContentHuggingPriority(.required, for: .horizontal)
        self.decimalLabel.setContentHuggingPriority(.required, for: .horizontal)
        
        var offset: CGFloat = 0
        if let font1 = self.integerLabel.font, let font2 = self.decimalLabel.font {
            offset = (font1.ascender - font1.capHeight) - (font2.ascender - font2.capHeight)
        }
        
        NSLayoutConstraint.activate([
            self.integerLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            self.integerLabel.topAnchor.constraint(equalTo: self.topAnchor),
            self.integerLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            
            self.decimalLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: offset),
            self.decimalLabel.leadingAnchor.constraint(equalTo: self.integerLabel.trailingAnchor),
            self.decimalLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor),
        ])
        
    }

    func updateLabels() {

        let integer = NumberFormatter.integer.string(from: self.price) ?? "0"
        self.integerLabel.text = integer

        let decimal = NumberFormatter.decimal.string(from: self.price)?.dropFirst().string ?? "00"
        self.decimalLabel.text = decimal

        self.setNeedsLayout()
    }
}
