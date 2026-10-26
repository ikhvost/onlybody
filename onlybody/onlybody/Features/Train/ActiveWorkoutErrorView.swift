import SwiftUI

struct ActiveWorkoutErrorView: View {
    let errorMessage: String?
    let onEnd: () -> Void

    var body: some View {
        VStack(spacing: Theme.space10) {
            MonoLabel(text: String(localized: .uiWorkoutUnavailable), size: Theme.type11, color: Theme.text2, tracking: 0.4)
            if let error = errorMessage {
                MonoLabel(text: error, size: Theme.type10, color: Theme.text3, tracking: 0.4)
            }
            GhostButton(title: String(localized: .uiClose), action: onEnd)
        }
    }
}
