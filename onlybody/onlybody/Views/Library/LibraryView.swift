import SwiftUI

struct LibraryView: View {
    var body: some View {
        ZStack {
            Theme.bg.ignoresSafeArea()
            VStack(spacing: Theme.space8) {
                MonoLabel(text: "Movement catalog", size: 10, tracking: 1.2)
                Text("Library")
                    .font(Theme.fontSans(26, .heavy))
                    .tracking(-1)
                    .foregroundStyle(Theme.text)
            }
        }
    }
}

#Preview("Library") {
    LibraryView()
        .preferredColorScheme(.dark)
}
