import UIKit

/// Adds an interactive back gesture near the edge while preserving the navigation owner's delegate.
final class ExpandedBackSwipe: NSObject, UIGestureRecognizerDelegate, UINavigationControllerDelegate {
    private weak var navigation: UINavigationController?
    private weak var previousDelegate: (any UINavigationControllerDelegate)?
    private var pan: UIPanGestureRecognizer?
    private var interaction: UIPercentDrivenInteractiveTransition?
    private var shouldBegin: () -> Bool = { true }
    private var detachAfterTransition = false
    private weak var source: UIViewController?

    func attach(to navigation: UINavigationController?, shouldBegin: @escaping () -> Bool) {
        self.shouldBegin = shouldBegin
        guard pan == nil, let navigation else { return }
        self.navigation = navigation
        let pan = UIPanGestureRecognizer(target: self, action: #selector(handlePan))
        pan.delegate = self
        pan.maximumNumberOfTouches = 1
        if let edge = navigation.interactivePopGestureRecognizer { pan.require(toFail: edge) }
        navigation.view.addGestureRecognizer(pan)
        self.pan = pan
    }

    func detach() {
        guard interaction == nil else {
            detachAfterTransition = true
            return
        }
        if let pan { pan.view?.removeGestureRecognizer(pan) }
        pan = nil
    }

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        guard let host = gestureRecognizer.view else { return false }
        let location = touch.location(in: host)
        let distance = host.effectiveUserInterfaceLayoutDirection == .rightToLeft
            ? host.bounds.maxX - location.x : location.x - host.bounds.minX
        // A horizontal back drag has priority throughout this narrow strip, including players and buttons.
        // Ordinary taps and vertical scrolling still fail the pan's direction check and pass through.
        return distance >= 0 && distance <= Theme.backSwipeStartWidth
    }

    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        guard let navigation, let pan,
              navigation.viewControllers.count > 1,
              navigation.transitionCoordinator == nil,
              navigation.presentedViewController == nil else { return false }
        let velocity = pan.velocity(in: pan.view)
        return velocity.x * direction > abs(velocity.y) * Theme.swipeDirectionRatio && shouldBegin()
    }

    func gestureRecognizer(
        _ gestureRecognizer: UIGestureRecognizer,
        shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer
    ) -> Bool {
        otherGestureRecognizer is UIPanGestureRecognizer && !(otherGestureRecognizer is UIScreenEdgePanGestureRecognizer)
    }

    private var direction: CGFloat {
        navigation?.view.effectiveUserInterfaceLayoutDirection == .rightToLeft ? -1 : 1
    }

    @objc private func handlePan(_ pan: UIPanGestureRecognizer) {
        guard let navigation else { return }
        let progress = min(1, max(0, pan.translation(in: pan.view).x * direction / navigation.view.bounds.width))
        switch pan.state {
        case .began:
            let interaction = UIPercentDrivenInteractiveTransition()
            interaction.completionCurve = .easeOut
            self.interaction = interaction
            source = navigation.topViewController
            previousDelegate = navigation.delegate
            navigation.delegate = self
            navigation.popViewController(animated: true)
        case .changed:
            interaction?.update(progress)
        case .ended:
            if progress > Theme.backSwipeCompletion || pan.velocity(in: pan.view).x * direction > Theme.backSwipeSpeed {
                interaction?.finish()
            } else {
                interaction?.cancel()
            }
        case .cancelled, .failed:
            interaction?.cancel()
        default:
            break
        }
    }

    func navigationController(
        _ navigationController: UINavigationController, animationControllerFor operation: UINavigationController.Operation,
        from fromVC: UIViewController, to toVC: UIViewController
    ) -> (any UIViewControllerAnimatedTransitioning)? {
        BackSwipeAnimator()
    }

    func navigationController(
        _ navigationController: UINavigationController,
        interactionControllerFor animationController: any UIViewControllerAnimatedTransitioning
    ) -> (any UIViewControllerInteractiveTransitioning)? {
        interaction
    }

    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        previousDelegate?.navigationController?(navigationController, willShow: viewController, animated: animated)
    }

    func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        let original = previousDelegate
        if navigationController.delegate === self { navigationController.delegate = original }
        interaction = nil
        original?.navigationController?(navigationController, didShow: viewController, animated: animated)
        if detachAfterTransition {
            detachAfterTransition = false
            if viewController !== source { detach() }
        }
        source = nil
    }
}
