import SwiftUI

/// A prominent system glass action for controls floating above scrollable content.
struct GlassActionButton: View {
    let title: String
    let action: () -> Void
    var disabled: Bool = false
    var minimumHeight: CGFloat = Theme.buttonHeight

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(Theme.fontSans(Theme.typeBody, .bold))
                .foregroundStyle(Theme.accentDark)
                .frame(maxWidth: .infinity, minHeight: minimumHeight)
        }
        .buttonStyle(.glassProminent)
        .buttonBorderShape(.capsule)
        .tint(Theme.accent)
        .disabled(disabled)
    }
}

#if DEBUG
#Preview("Glass actions") {
    VStack(spacing: Theme.space16) {
        GlassActionButton(title: String(localized: .uiSave), action: {})
        GlassActionButton(title: String(localized: .uiDone), action: {}, disabled: true)
    }
    .padding(Theme.horizontalPadding)
    .background(Theme.bg)
    .preferredColorScheme(.dark)
}
#endif
