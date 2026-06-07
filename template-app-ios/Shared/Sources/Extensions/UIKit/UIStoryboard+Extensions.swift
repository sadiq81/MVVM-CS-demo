import UIKit

import MustacheUIKit

@MainActor
public enum AppStoryboard {
     
    public static func viewController<T: UIViewController>(class: T.Type, from bundle: Bundle = .main) -> T {
        let storyboardIdentifier = T.storyboardID
        let storyboard = UIStoryboard(name: storyboardIdentifier, bundle: bundle)
        guard let controller = storyboard.instantiateViewController(withIdentifier: storyboardIdentifier) as? T else {
            fatalError("unable to instantiate viewController \(String(describing: `class`))")
        }
        return controller
    }
    
}
