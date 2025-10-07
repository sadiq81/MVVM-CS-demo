import UIKit

class FadePopAnimation: NSObject, UIViewControllerAnimatedTransitioning {

    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.3
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard
            let toViewController = transitionContext.viewController(forKey: .to),
            let fromViewController = transitionContext.viewController(forKey: .from)
        else {
            transitionContext.completeTransition(false)
            return
        }
                
        toViewController.beginAppearanceTransition(true, animated: true)
        fromViewController.beginAppearanceTransition(false, animated: true)
        
        toViewController.view.frame = fromViewController.view.frame
        toViewController.view.alpha = 0.0
        
        transitionContext.containerView.insertSubview(toViewController.view, belowSubview: fromViewController.view)

        UIView.animate(
            withDuration: self.transitionDuration(using: transitionContext),
            animations: {
                toViewController.view.alpha = 1.0
                fromViewController.view.alpha = 0.0
            },
            completion: { (finished) in
                toViewController.endAppearanceTransition()
                fromViewController.endAppearanceTransition()
                transitionContext.completeTransition(finished && !transitionContext.transitionWasCancelled)
            })
    }

    deinit {
        debugPrint("deinit \(self)")
    }

}
