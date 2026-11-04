import SwiftUI

struct NavBarView<Leading: View, Trailing: View>: View {
    let title: String?
    private let leading: Leading
    private let trailing: Trailing

    init(
        title: String? = nil,
        @ViewBuilder leading: () -> Leading,
        @ViewBuilder trailing: () -> Trailing
    ) {
        self.title = title
        self.leading = leading()
        self.trailing = trailing()
    }

    var body: some View {
        CenteredNavigationLayout(spacing: Theme.space10) {
            ZStack { leading }
                .buttonStyle(.glass).buttonBorderShape(.circle)
                .frame(minWidth: Theme.touchSize, minHeight: Theme.touchSize)
                .fixedSize(horizontal: true, vertical: false)

            if let title {
                Text(title)
                    .font(Theme.fontSans(Theme.typeCard, .bold))
                    .tracking(-0.2)
                    .foregroundStyle(Theme.text)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(maxWidth: .infinity)
                    .accessibilityIdentifier("navigation.title")
            } else {
                Spacer(minLength: Theme.space0)
            }

            ZStack { trailing }
                .fixedSize(horizontal: true, vertical: false)
        }
        .padding(.horizontal, Theme.horizontalPadding)
        .padding(.vertical, Theme.space10)
    }

    init(
        title: String? = nil,
        @ViewBuilder leading: () -> Leading
    ) where Trailing == EmptyView {
        self.init(title: title, leading: leading) {
            EmptyView()
        }
    }
}
