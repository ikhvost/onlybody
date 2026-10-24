import SwiftUI

struct TabSwipeBridge: UIViewControllerRepresentable {
    let isEnabled: Bool
    let onSwipe: (Bool) -> Void

    func makeUIViewController(context: Context) -> TabSwipeController { TabSwipeController() }

    func updateUIViewController(_ controller: TabSwipeController, context: Context) {
        controller.isEnabled = isEnabled
        controller.onSwipe = onSwipe
    }

    static func dismantleUIViewController(_ controller: TabSwipeController, coordinator: ()) {
        controller.detach()
    }
}
