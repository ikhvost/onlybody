import UIKit

/// Slides the current screen with the finger and reveals the previous screen underneath.
final class BackSwipeAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    func transitionDuration(using transitionContext: (any UIViewControllerContextTransitioning)?) -> TimeInterval {
        Theme.backSwipeDuration
    }

    func animateTransition(using transitionContext: any UIViewControllerContextTransitioning) {
        guard let from = transitionContext.view(forKey: .from),
              let to = transitionContext.view(forKey: .to),
              let destination = transitionContext.viewController(forKey: .to) else {
            transitionContext.completeTransition(false)
            return
        }
        let container = transitionContext.containerView
        let direction: CGFloat = container.effectiveUserInterfaceLayoutDirection == .rightToLeft ? -1 : 1
        let width = container.bounds.width * direction
        to.frame = transitionContext.finalFrame(for: destination)
        container.insertSubview(to, belowSubview: from)
        let parallax = UIAccessibility.isReduceMotionEnabled ? 0 : Theme.backSwipeParallax
        to.transform = CGAffineTransform(translationX: -width * parallax, y: 0)
        UIView.animate(withDuration: transitionDuration(using: transitionContext), delay: 0, options: .curveLinear) {
            from.transform = CGAffineTransform(translationX: width, y: 0)
            to.transform = .identity
        } completion: { _ in
            from.transform = .identity
            to.transform = .identity
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        }
    }
}
