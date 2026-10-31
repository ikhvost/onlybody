import SwiftUI

struct BottomNavButton<Icon: View>: View {
    let isSelected: Bool
    let action: () -> Void
    let label: String
    @ViewBuilder let icon: () -> Icon

    var body: some View {
        Button {
            action()
        } label: {
            VStack(spacing: Theme.space6) {
                icon()

                MonoLabel(
                    text: label,
                    size: Theme.typeMeta,
                    color: isSelected ? Theme.accent : Theme.text2,
                    tracking: 1.2
                )
                .fixedSize(horizontal: false, vertical: true)
                .multilineTextAlignment(.center)

                Rectangle()
                    .fill(isSelected ? Theme.accent : Color.clear)
                    .frame(width: 16, height: 2)
                    .clipShape(.rect(cornerRadius: 1))
            }
            .frame(maxWidth: .infinity, minHeight: Theme.buttonHeight)
        }
        .frame(maxWidth: .infinity, minHeight: Theme.buttonHeight)
        .background(isSelected ? Theme.accentDim : .clear, in: .rect(cornerRadius: Theme.buttonRadius))
        .accessibilityAddTraits(isSelected ? .isSelected : [])
        .buttonStyle(PressableButtonStyle())
    }
}
