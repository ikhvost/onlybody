import SwiftUI

/// Monochrome OnlyBody monogram shared by the icon and launch-artwork renderer.
struct OBMarkView: View {
    let size: CGFloat

    var body: some View {
        ZStack {
            Text("O")
                .font(Theme.fontSans(size * Theme.brandLetterScale, .black).italic())
                .foregroundStyle(Theme.brandSecondary)
                .offset(x: -size * Theme.brandLetterOffset)
            Text("B")
                .font(Theme.fontSans(size * Theme.brandLetterScale, .black).italic())
                .foregroundStyle(Theme.brandPrimary)
                .offset(x: size * Theme.brandLetterOffset)
        }
        .frame(width: size, height: size)
        .accessibilityLabel("OnlyBody")
    }
}
