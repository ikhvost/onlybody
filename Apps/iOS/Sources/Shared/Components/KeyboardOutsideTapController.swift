import UIKit

/// Lets text inputs and buttons receive their original touches while dismissing outside editing.
final class KeyboardOutsideTapController: UIViewController, UIGestureRecognizerDelegate {
    var isEnabled = false
    var onDismiss: () -> Void = {}
    private weak var gestureHost: UIView?
    private lazy var tap: UITapGestureRecognizer = {
        let gesture = UITapGestureRecognizer(target: self, action: #selector(dismissEditing))
        gesture.cancelsTouchesInView = false
        gesture.delaysTouchesBegan = false
        gesture.delaysTouchesEnded = false
        gesture.delegate = self
        return gesture
    }()

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        attach()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        attach()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        detach()
    }

    func attach() {
        guard viewIfLoaded?.window != nil, let host = parent?.view, gestureHost !== host else { return }
        detach()
        host.addGestureRecognizer(tap)
        gestureHost = host
    }

    func detach() {
        gestureHost?.removeGestureRecognizer(tap)
        gestureHost = nil
    }

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        guard isEnabled else { return false }
        var target = touch.view
        while let view = target {
            if view is UITextField || view is UITextView { return false }
            target = view.superview
        }
        return true
    }

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
                           shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        true
    }

    @objc private func dismissEditing() { onDismiss() }
}
