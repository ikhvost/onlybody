import SwiftUI

/// Observes outside taps without placing a hit-testing layer over screen controls.
struct KeyboardOutsideTapBridge: UIViewControllerRepresentable {
    let isEnabled: Bool
    let onDismiss: () -> Void

    func makeUIViewController(context: Context) -> KeyboardOutsideTapController {
        KeyboardOutsideTapController()
    }

    func updateUIViewController(_ controller: KeyboardOutsideTapController, context: Context) {
        controller.isEnabled = isEnabled
        controller.onDismiss = onDismiss
        controller.attach()
    }

    static func dismantleUIViewController(_ controller: KeyboardOutsideTapController, coordinator: ()) {
        controller.detach()
        controller.onDismiss = {}
    }
}
