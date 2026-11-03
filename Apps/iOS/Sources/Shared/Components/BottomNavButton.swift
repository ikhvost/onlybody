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
            VStack(spacing: Theme.space4) {
                icon()

                MonoLabel(
                    text: label,
                    size: Theme.type12,
                    color: isSelected ? Theme.accent : Theme.text2,
                    tracking: 0
                )
                .fixedSize(horizontal: false, vertical: true)
                .multilineTextAlignment(.center)

            }
            .frame(maxWidth: .infinity, minHeight: Theme.bottomNavigationHeight)
        }
        .frame(maxWidth: .infinity, minHeight: Theme.bottomNavigationHeight)
        .background(isSelected ? Theme.surface2 : .clear, in: .capsule)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
        .buttonStyle(PressableButtonStyle())
    }
}
