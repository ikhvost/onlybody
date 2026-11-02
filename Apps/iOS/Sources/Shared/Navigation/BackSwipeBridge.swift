import SwiftUI

/// Enables native interactive pop on this screen while keeping SwiftUI's path ownership.
struct BackSwipeBridge: UIViewControllerRepresentable {
    var shouldBegin: () -> Bool = { true }

    func makeUIViewController(context: Context) -> BackSwipeController {
        BackSwipeController()
    }

    func updateUIViewController(_ controller: BackSwipeController, context: Context) {
        controller.shouldBegin = shouldBegin
    }

    static func dismantleUIViewController(_ controller: BackSwipeController, coordinator: ()) {
        controller.detach()
    }
}
