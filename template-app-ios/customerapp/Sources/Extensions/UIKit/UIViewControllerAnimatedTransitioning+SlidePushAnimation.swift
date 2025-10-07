import UIKit

class SlidePushAnimation: NSObject, UIViewControllerAnimatedTransitioning {
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.3
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        
        guard
            let toViewController = transitionContext.viewController(forKey: .to),
            let fromView = transitionContext.view(forKey: .from)
        else { return }
        
        let width = fromView.frame.width
        
        transitionContext.containerView.addSubview(toViewController.view)
        toViewController.view.transform = .init(translationX: width, y: 1)
        
        let duration = self.transitionDuration(using: transitionContext)
        
        UIView.animate(
            withDuration: duration,
            animations: {
                toViewController.view.transform = .identity
                fromView.transform = .init(translationX: -width, y: 1)
            },
            completion: { _ in
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
            })
    }
    
    deinit {
        debugPrint("deinit \(self)")
    }
    
}
