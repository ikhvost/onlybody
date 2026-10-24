import SwiftUI

/// Monochrome OnlyWeights monogram shared by the icon and launch-artwork renderer.
struct OWMarkView: View {
    let size: CGFloat

    var body: some View {
        ZStack {
            Text("O")
                .font(Theme.fontSans(size * Theme.brandLetterScale, .black).italic())
                .foregroundStyle(Theme.brandSecondary)
                .offset(x: -size * Theme.brandLetterOffset)
            Text("W")
                .font(Theme.fontSans(size * Theme.brandLetterScale, .black).italic())
                .foregroundStyle(Theme.brandPrimary)
                .offset(x: size * Theme.brandLetterOffset)
        }
        .frame(width: size, height: size)
        .accessibilityLabel("OnlyWeights")
    }
}
