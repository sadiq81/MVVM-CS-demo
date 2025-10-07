
import UIKit

/// Subclassing this will add a dark transparent background to dim the underlying content.
/// Use it fx. to present a bottom sheet with modalPresentationStyle = .overFullScreen
class BackgroundDimmingViewController: UIViewController {
    
    private lazy var dimmingView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configure()
        self.configureConstraints()
    }
    
    private func configure() {
        self.view.addSubview(self.dimmingView)
        self.view.sendSubviewToBack(self.dimmingView)        
    }
    
    private func configureConstraints() {
        NSLayoutConstraint.activate([
            self.dimmingView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            self.dimmingView.widthAnchor.constraint(equalTo: self.view.widthAnchor),
            self.dimmingView.heightAnchor.constraint(equalTo: self.view.heightAnchor, multiplier: 2),
            self.dimmingView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
        ])
    }
    
    override func viewIsAppearing(_ animated: Bool) {
        super.viewIsAppearing(animated)
        UIView.animate(withDuration: 0.3) {
            self.dimmingView.backgroundColor = .black.withAlphaComponent(0.7)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        UIView.animate(withDuration: 0.3) {
            self.dimmingView.backgroundColor = .clear
        }
    }
    
}
