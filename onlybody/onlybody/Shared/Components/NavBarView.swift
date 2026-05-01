import SwiftUI

struct NavBarView<Leading: View, Trailing: View>: View {
    let title: String
    private let leading: Leading
    private let trailing: Trailing

    init(
        title: String,
        @ViewBuilder leading: () -> Leading,
        @ViewBuilder trailing: () -> Trailing
    ) {
        self.title = title
        self.leading = leading()
        self.trailing = trailing()
    }

    var body: some View {
        HStack(spacing: Theme.space10) {
            leading
                .frame(maxWidth: .infinity, alignment: .leading)

            Text(title)
                .font(Theme.fontSans(15, .bold))
                .tracking(-0.2)
                .foregroundStyle(Theme.text)
                .frame(maxWidth: .infinity)

            trailing
                .frame(maxWidth: .infinity, alignment: .trailing)
        }
        .padding(.horizontal, Theme.horizontalPadding)
        .padding(.vertical, Theme.space10)
        .overlay(alignment: .bottom) {
            Rectangle()
                .fill(Theme.border)
                .frame(height: 1)
        }
    }
}
