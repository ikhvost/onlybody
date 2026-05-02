import SwiftUI

struct TrainHeaderView: View {
    let dateDisplay: String
    let onCreateTap: () -> Void
    let onTitleTap: () -> Void

    var body: some View {
        HStack(alignment: .bottom) {
            VStack(alignment: .leading, spacing: Theme.space3) {
                Button {
                    onTitleTap()
                } label: {
                    MonoLabel(
                        text: dateDisplay,
                        size: 9,
                        color: Theme.text3,
                        tracking: 1.2
                    )
                }
                .buttonStyle(.plain)

                Button {
                    onTitleTap()
                } label: {
                    Text("OnlyBody")
                        .font(Theme.fontSans(26, .heavy))
                        .tracking(-1)
                        .foregroundStyle(Theme.text)
                }
                .buttonStyle(.plain)
            }

            Spacer()

            Button {
                onCreateTap()
            } label: {
                ZStack {
                    RoundedRectangle(cornerRadius: Theme.cornerRadius)
                        .fill(Theme.accent)
                        .frame(width: 34, height: 34)

                    PlusIcon(color: Theme.accentDark, size: 15)
                }
            }
            .accessibilityLabel("Create workout")
        }
        .padding(.horizontal, Theme.horizontalPadding)
        .padding(.top, Theme.space16)
        .padding(.bottom, Theme.space10)
    }
}
