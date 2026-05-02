import SwiftUI

struct ChipView: View {
    let label: String
    let isActive: Bool
    let isSmall: Bool
    let size: CGFloat
    let cornerRadius: CGFloat
    let horizontalPadding: CGFloat
    let verticalPadding: CGFloat
    let action: () -> Void

    init(
        label: String,
        isActive: Bool,
        isSmall: Bool = false,
        size: CGFloat? = nil,
        cornerRadius: CGFloat? = nil,
        horizontalPadding: CGFloat? = nil,
        verticalPadding: CGFloat? = nil,
        action: @escaping () -> Void
    ) {
        self.label = label
        self.isActive = isActive
        self.isSmall = isSmall
        self.size = size ?? (isSmall ? 11 : 13)
        self.cornerRadius = cornerRadius ?? Theme.chipCornerRadius
        self.horizontalPadding = horizontalPadding ?? (isSmall ? 10 : 15)
        self.verticalPadding = verticalPadding ?? (isSmall ? 5 : 8)
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            Text(label)
                .font(Theme.fontSans(size, .semibold))
                .foregroundStyle(isActive ? Theme.accentDark : Theme.text2)
                .padding(.horizontal, horizontalPadding)
                .padding(.vertical, verticalPadding)
                .background(isActive ? Theme.accent : Theme.surface2)
                .overlay {
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .stroke(isActive ? Theme.accent : Theme.border2, lineWidth: 1)
                }
                .clipShape(.rect(cornerRadius: cornerRadius))
        }
        .buttonStyle(.plain)
    }
}
