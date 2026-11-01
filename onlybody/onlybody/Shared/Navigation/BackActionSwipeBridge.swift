import SwiftUI

/// Routes a back swipe to the same action as a back button on a modal or state-based page.
struct BackActionSwipeBridge: UIViewControllerRepresentable {
    var isEnabled = true
    let onBack: () -> Void

    func makeUIViewController(context: Context) -> BackActionSwipeController { BackActionSwipeController() }

    func updateUIViewController(_ controller: BackActionSwipeController, context: Context) {
        controller.isEnabled = isEnabled
        controller.onBack = onBack
        controller.attach()
    }

    static func dismantleUIViewController(_ controller: BackActionSwipeController, coordinator: ()) {
        controller.detach()
        controller.onBack = {}
    }
}
