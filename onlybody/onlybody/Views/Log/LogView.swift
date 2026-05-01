import SwiftUI

struct LogView: View {
    var body: some View {
        ZStack {
            Theme.bg.ignoresSafeArea()
            VStack(spacing: Theme.space8) {
                MonoLabel(text: "Training history", size: 10, tracking: 1.2)
                Text("Log")
                    .font(Theme.fontSans(26, .heavy))
                    .tracking(-1)
                    .foregroundStyle(Theme.text)
            }
        }
    }
}

#Preview("Log") {
    LogView()
        .preferredColorScheme(.dark)
}
