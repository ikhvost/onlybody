import SwiftUI

struct TrainHeader: View {
    let dateDisplay: String
    let onCreateTap: () -> Void

    var body: some View {
        HStack(alignment: .bottom) {
            VStack(alignment: .leading, spacing: Theme.space3) {
                MonoLabel(text: dateDisplay, size: Theme.type10, color: Theme.text3, tracking: 1.2)
                Text("OnlyBody")
                    .font(Theme.fontSans(Theme.type28, .heavy))
                    .tracking(-1)
                    .foregroundStyle(Theme.text)
            }

            Spacer()

            Button {
                onCreateTap()
            } label: {
                ZStack {
                    RoundedRectangle(cornerRadius: Theme.cornerRadius)
                        .fill(Theme.accent)
                        .frame(width: 38, height: 38)

                    PlusIcon(color: Theme.accentDark, size: Theme.type15)
                }
            }
            .accessibilityLabel("Create workout")
            .accessibilityIdentifier("workout.create")
            .buttonStyle(PressableButtonStyle())
        }
        .padding(.horizontal, Theme.horizontalPadding)
        .padding(.top, Theme.space16)
        .padding(.bottom, Theme.space10)
    }
}
