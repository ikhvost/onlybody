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
        HStack(spacing: Theme.space10) {
            leading
                .fixedSize(horizontal: true, vertical: false)

            if let title {
                Text(title)
                    .font(Theme.fontSans(Theme.type16, .bold))
                    .tracking(-0.2)
                    .foregroundStyle(Theme.text)
                    .lineLimit(1)
                    .frame(maxWidth: .infinity)
            } else {
                Spacer(minLength: Theme.space0)
            }

            trailing
                .fixedSize(horizontal: true, vertical: false)
        }
        .padding(.horizontal, Theme.horizontalPadding)
        .padding(.vertical, Theme.space10)
        .overlay(alignment: .bottom) {
            Rectangle()
                .fill(Theme.border)
                .frame(height: 1)
        }
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
