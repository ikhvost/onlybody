import UIKit
import WebKit

/// Observes content drags without intercepting taps or vertical scrolling.
final class TabSwipeController: UIViewController, UIGestureRecognizerDelegate {
    var isEnabled = false
    var onSwipe: (Bool) -> Void = { _ in }
    private var pan: UIPanGestureRecognizer?

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        guard pan == nil, let host = parent?.view else { return }
        let gesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan))
        gesture.delegate = self
        gesture.cancelsTouchesInView = false
        host.addGestureRecognizer(gesture)
        pan = gesture
    }

    func detach() {
        if let pan { pan.view?.removeGestureRecognizer(pan) }
        pan = nil
    }

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        guard isEnabled, presentedViewController == nil, parent?.presentedViewController == nil,
              view.window?.rootViewController?.presentedViewController == nil,
              view.bounds.contains(touch.location(in: view)) else { return false }
        var ancestor = touch.view
        while let current = ancestor {
            if current is UIControl || current is UITextView || current is WKWebView { return false }
            if let scroll = current as? UIScrollView,
               scroll.alwaysBounceHorizontal || scroll.contentSize.width > scroll.bounds.width + 1 { return false }
            ancestor = current.superview
        }
        return true
    }

    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        guard isEnabled, let pan = gestureRecognizer as? UIPanGestureRecognizer else { return false }
        let velocity = pan.velocity(in: pan.view)
        return abs(velocity.x) > abs(velocity.y) * Theme.swipeDirectionRatio
    }

    func gestureRecognizer(
        _ gestureRecognizer: UIGestureRecognizer,
        shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer
    ) -> Bool {
        otherGestureRecognizer is UIPanGestureRecognizer && !(otherGestureRecognizer is UIScreenEdgePanGestureRecognizer)
    }

    @objc private func handlePan(_ gesture: UIPanGestureRecognizer) {
        guard isEnabled, gesture.state == .ended else { return }
        let distance = gesture.translation(in: gesture.view)
        let velocity = gesture.velocity(in: gesture.view)
        guard TabSwipeDecision.accepts(
            horizontal: distance.x, vertical: distance.y, velocity: velocity.x,
            thresholds: Theme.tabSwipeThresholds
        ) else { return }
        onSwipe(distance.x < 0)
    }
}
