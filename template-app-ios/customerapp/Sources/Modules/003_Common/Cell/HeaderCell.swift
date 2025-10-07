
import Foundation
import UIKit

class HeaderCell: UICollectionReusableView {
    
    let label = UILabel()
    
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
    
    private func configure() {
        
        self.label.font = UIFont.preferredFont(forTextStyle: .caption2.emphasized)
        self.label.textColor = Colors.Foreground.default.color
        self.addSubview(self.label)
        
        self.backgroundColor = Colors.Background.neutralSubtle.color
        self.clipsToBounds = true
        
    }
    
    private func configureConstraints() {
        
        self.label.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            self.label.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 16),
            self.label.topAnchor.constraint(equalTo: self.topAnchor, constant: 6),
            self.label.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -6),
        ])
    }
    
}

