import SwiftUI

struct ChipView: View {
    let label: String
    let isActive: Bool
    let isSmall: Bool
    let action: () -> Void

    init(label: String, isActive: Bool, isSmall: Bool = false, action: @escaping () -> Void) {
        self.label = label
        self.isActive = isActive
        self.isSmall = isSmall
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            Text(label)
                .font(Theme.fontSans(isSmall ? 11 : 13, .semibold))
                .foregroundStyle(isActive ? Theme.accentDark : Theme.text2)
                .padding(.horizontal, isSmall ? 10 : 15)
                .padding(.vertical, isSmall ? 5 : 8)
                .background(isActive ? Theme.accent : Theme.surface2)
                .overlay {
                    RoundedRectangle(cornerRadius: Theme.chipCornerRadius)
                        .stroke(isActive ? Theme.accent : Theme.border2, lineWidth: 1)
                }
                .clipShape(.rect(cornerRadius: Theme.chipCornerRadius))
        }
        .buttonStyle(.plain)
    }
}
