import UIKit

final class BackActionSwipeController: UIViewController, UIGestureRecognizerDelegate {
    var isEnabled = true
    var onBack: () -> Void = {}
    private weak var host: UIView?
    private lazy var pan: UIPanGestureRecognizer = {
        let gesture = UIPanGestureRecognizer(target: self, action: #selector(handleSwipe))
        gesture.maximumNumberOfTouches = 1
        gesture.delegate = self
        return gesture
    }()

    override func viewDidAppear(_ animated: Bool) { super.viewDidAppear(animated); attach() }
    override func viewDidLayoutSubviews() { super.viewDidLayoutSubviews(); attach() }
    override func viewWillDisappear(_ animated: Bool) { super.viewWillDisappear(animated); detach() }

    func attach() {
        guard viewIfLoaded?.window != nil, let parent, let target = parent.view, host !== target else { return }
        if let navigation = parent.navigationController, navigation.topViewController !== parent { return }
        detach()
        target.addGestureRecognizer(pan)
        host = target
    }

    func detach() { host?.removeGestureRecognizer(pan); host = nil }

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        guard isEnabled, let host else { return false }
        let x = touch.location(in: host).x
        let distance = direction > 0 ? x - host.bounds.minX : host.bounds.maxX - x
        return distance >= 0 && distance <= Theme.backSwipeStartWidth
    }

    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        let velocity = pan.velocity(in: host)
        return isEnabled && velocity.x * direction > abs(velocity.y) * Theme.swipeDirectionRatio
    }

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
                           shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        otherGestureRecognizer is UIPanGestureRecognizer && !(otherGestureRecognizer is UIScreenEdgePanGestureRecognizer)
    }

    private var direction: CGFloat { host?.effectiveUserInterfaceLayoutDirection == .rightToLeft ? -1 : 1 }

    @objc private func handleSwipe() {
        guard pan.state == .ended, isEnabled, let host else { return }
        let distance = pan.translation(in: host).x * direction
        if distance > host.bounds.width * Theme.backSwipeCompletion || pan.velocity(in: host).x * direction > Theme.backSwipeSpeed {
            onBack()
        }
    }
}
