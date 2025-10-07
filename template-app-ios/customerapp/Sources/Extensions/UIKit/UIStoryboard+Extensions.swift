
import MustacheUIKit

public enum AppStoryboard {
     
    public static func viewController<T: UIViewController>(class: T.Type, from bundle: Bundle = .main) -> T {
        let storyBoardId = T.storyboardID
        let storyBoard = UIStoryboard(name: storyBoardId, bundle: bundle)
        guard let controller = storyBoard.instantiateViewController(withIdentifier: storyBoardId) as? T else {
            fatalError("unable to instantiate viewController \(String(describing: `class`))")
        }
        return controller
    }
    
}
