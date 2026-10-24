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
                    size: Theme.type10,
                    color: isSelected ? Theme.accent : Theme.text3,
                    tracking: 1.2
                )

                Rectangle()
                    .fill(isSelected ? Theme.accent : Color.clear)
                    .frame(width: 16, height: 2)
                    .clipShape(.rect(cornerRadius: 1))
            }
        }
        .frame(maxWidth: .infinity)
        .buttonStyle(PressableButtonStyle())
    }
}
