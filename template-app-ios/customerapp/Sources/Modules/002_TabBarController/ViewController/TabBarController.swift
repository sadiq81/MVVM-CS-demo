
import Foundation
import UIKit

import MustacheServices

class TabBarController: UITabBarController {
    
    var coordinator: CoordinatorType!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.configure()
        self.configureConstraints()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    private func configure() {}
    
    private func configureConstraints() {}
    
    deinit {
        debugPrint("deinit: \(self)")
    }
    
}

