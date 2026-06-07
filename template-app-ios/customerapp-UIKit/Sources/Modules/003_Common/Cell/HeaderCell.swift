import Foundation
import UIKit

final class HeaderCell: UICollectionReusableView {
    
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
        
        self.backgroundColor = .white
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

#if DEBUG
#Preview("HeaderCell") {
    let cell = HeaderCell(frame: CGRect(x: 0, y: 0, width: 375, height: 44))
    cell.label.text = "Section Header"
    return cell
}
#endif

