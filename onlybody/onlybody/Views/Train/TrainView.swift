import SwiftUI

struct TrainView: View {
    var body: some View {
        ZStack {
            Theme.bg.ignoresSafeArea()
            VStack(spacing: Theme.space8) {
                MonoLabel(text: "Ready to train", size: 10, tracking: 1.2)
                Text("OnlyBody")
                    .font(Theme.fontSans(26, .heavy))
                    .tracking(-1)
                    .foregroundStyle(Theme.text)
            }
        }
    }
}

#Preview("Train") {
    TrainView()
        .preferredColorScheme(.dark)
}
