import SwiftUI

struct TabSwipeBridge: UIViewControllerRepresentable {
    let isEnabled: Bool
    let onDrag: (CGFloat) -> Void
    let onEnd: (Bool?) -> Void

    func makeUIViewController(context: Context) -> TabSwipeController { TabSwipeController() }

    func updateUIViewController(_ controller: TabSwipeController, context: Context) {
        controller.isEnabled = isEnabled
        controller.onDrag = onDrag
        controller.onEnd = onEnd
    }

    static func dismantleUIViewController(_ controller: TabSwipeController, coordinator: ()) {
        controller.detach()
    }
}
