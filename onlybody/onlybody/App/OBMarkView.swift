import SwiftUI

struct OBMarkView: View {
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
