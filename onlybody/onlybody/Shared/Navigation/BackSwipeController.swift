import UIKit

final class BackSwipeController: UIViewController, UIGestureRecognizerDelegate {
    var shouldBegin: () -> Bool = { true }
    private weak var popGesture: UIGestureRecognizer?
    private weak var previousDelegate: (any UIGestureRecognizerDelegate)?
    private var previousEnabled = false
    private weak var contentGesture: UIGestureRecognizer?
    private var previousContentEnabled = false

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        attach()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        attach()
    }

    private func attach() {
        guard view.window != nil, navigationController?.topViewController === parent else { return }
        guard let gesture = navigationController?.interactivePopGestureRecognizer else { return }
        if popGesture !== gesture {
            previousDelegate = gesture.delegate
            previousEnabled = gesture.isEnabled
            popGesture = gesture
            contentGesture = navigationController?.interactiveContentPopGestureRecognizer
            previousContentEnabled = contentGesture?.isEnabled ?? false
        }
        // iOS 26 also offers full-content pop; this app deliberately reserves back for the edge.
        contentGesture?.isEnabled = false
        gesture.delegate = self
        gesture.isEnabled = true
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        detach()
    }

    func detach() {
        if let gesture = popGesture, gesture.delegate === self {
            let originalDelegate = previousDelegate
            let enabled = previousEnabled
            let content = contentGesture
            let contentEnabled = previousContentEnabled
            gesture.delegate = originalDelegate
            if let transition = navigationController?.transitionCoordinator, transition.isInteractive {
                // Disabling the recognizer here would cancel an in-flight interactive pop.
                transition.animate(alongsideTransition: nil) { _ in
                    if gesture.delegate === originalDelegate {
                        gesture.isEnabled = enabled
                        content?.isEnabled = contentEnabled
                    }
                }
            } else {
                gesture.isEnabled = enabled
                content?.isEnabled = contentEnabled
            }
        }
        popGesture = nil
        contentGesture = nil
    }

    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        guard let navigationController,
              navigationController.viewControllers.count > 1,
              navigationController.transitionCoordinator == nil,
              navigationController.presentedViewController == nil else { return false }
        return shouldBegin()
    }
}
