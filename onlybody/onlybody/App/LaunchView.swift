import SwiftUI

struct LaunchView: View {
    var body: some View {
        ZStack {
            Theme.bg.ignoresSafeArea()

            RadialGradient(
                gradient: Gradient(colors: [
                    Theme.accent.opacity(0.055),
                    Color.clear
                ]),
                center: .center,
                startRadius: 0,
                endRadius: 400
            )
            .ignoresSafeArea()

            VStack(spacing: Theme.space28) {
                OBMarkView(size: Theme.type112)

                VStack(spacing: Theme.space6) {
                    HStack(spacing: Theme.space0) {
                        Text("Only")
                            .font(Theme.fontSans(Theme.type26, .heavy))
                            .foregroundStyle(Theme.text)
                        Text("Body")
                            .font(Theme.fontSans(Theme.type26, .heavy))
                            .foregroundStyle(Theme.accent)
                    }

                    Text("CALISTHENICS TRAINING")
                        .font(Theme.fontSans(Theme.type11, .regular))
                        .foregroundStyle(Theme.iconDim)
                        .tracking(2.4)
                }
            }
        }
    }
}
