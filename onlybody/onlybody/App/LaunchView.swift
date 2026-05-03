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

            VStack(spacing: 28) {
                OBMarkView(size: 112)

                VStack(spacing: 6) {
                    HStack(spacing: 0) {
                        Text("Only")
                            .font(Theme.fontSans(26, .heavy))
                            .foregroundStyle(Theme.text)
                        Text("Body")
                            .font(Theme.fontSans(26, .heavy))
                            .foregroundStyle(Theme.accent)
                    }

                    Text("CALISTHENICS TRAINING")
                        .font(Theme.fontSans(11, .regular))
                        .foregroundStyle(Theme.iconDim)
                        .tracking(2.4)
                }
            }
        }
    }
}

private struct OBMarkView: View {
    let size: CGFloat

    var body: some View {
        ZStack {
            Circle()
                .fill(
                    RadialGradient(
                        gradient: Gradient(colors: [
                            Theme.accent.opacity(0.18),
                            Color.clear
                        ]),
                        center: .center,
                        startRadius: 0,
                        endRadius: size * 0.7
                    )
                )
                .frame(width: size, height: size)
                .blur(radius: size * 0.10)

            ZStack {
                Text("O")
                    .font(Theme.fontSans(size * 0.68, .black).italic())
                    .foregroundStyle(Theme.accent)
                    .shadow(color: Theme.accent.opacity(0.55), radius: size * 0.06)
                    .offset(x: -size * 0.13, y: -size * 0.01)

                Text("B")
                    .font(Theme.fontSans(size * 0.68, .black).italic())
                    .foregroundStyle(Theme.text)
                    .offset(x: size * 0.13, y: -size * 0.01)
            }

            Rectangle()
                .fill(Theme.accent)
                .frame(width: size * 0.74, height: max(1.5, size * 0.022))
                .offset(y: size * 0.32)
        }
        .frame(width: size, height: size)
    }
}
