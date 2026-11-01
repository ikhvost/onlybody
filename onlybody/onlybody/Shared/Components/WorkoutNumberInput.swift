import SwiftUI

/// Large numeric editing surface; validation and committed values belong to the owning screen model.
struct WorkoutNumberInput: View {
    let title: String
    let identifier: String
    @Binding var text: String
    var isDecimal = false
    var editingID = ""
    let hasError: Bool
    let canDecrease: Bool
    let onDecrease: () -> Void
    let onIncrease: () -> Void
    @FocusState private var focused: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: Theme.space12) {
            Text(title).font(Theme.fontSans(Theme.typeMeta)).foregroundStyle(Theme.text2)
                .accessibilityIdentifier("number.\(identifier).title")
            HStack(spacing: Theme.space12) {
                Button(action: onDecrease) {
                    Text("−").font(Theme.fontSans(Theme.typeCard))
                        .frame(width: Theme.stepSize, height: Theme.stepSize)
                        .background(Theme.surface2, in: .rect(cornerRadius: Theme.buttonRadius))
                }
                .disabled(!canDecrease || hasError).buttonStyle(PressableButtonStyle(animates: false))
                .accessibilityLabel(String(localized: .uiDecrease(title)))
                .accessibilityIdentifier("stepper.\(identifier).decrease")
                TextField(title, text: $text, prompt: Text(title).foregroundStyle(Theme.text3))
                    .keyboardType(isDecimal ? .decimalPad : .numberPad).focused($focused)
                    .onSubmit { if !hasError { focused = false } }
                    .font(Theme.fontMono(Theme.typeNumber, .medium)).multilineTextAlignment(.center)
                    .frame(minHeight: Theme.stepSize)
                    .overlay(alignment: .bottom) {
                        Rectangle().fill(hasError ? Theme.danger : focused ? Theme.accent : Theme.border2)
                            .frame(height: Theme.dividerThickness)
                    }
                    .accessibilityLabel(title).accessibilityIdentifier("stepper.\(identifier).value")
                Button(action: onIncrease) {
                    Text("+").font(Theme.fontSans(Theme.typeCard))
                        .frame(width: Theme.stepSize, height: Theme.stepSize)
                        .background(Theme.surface2, in: .rect(cornerRadius: Theme.buttonRadius))
                }
                .disabled(hasError).buttonStyle(PressableButtonStyle(animates: false))
                .accessibilityLabel(String(localized: .uiIncrease(title)))
                .accessibilityIdentifier("stepper.\(identifier).increase")
            }
            if hasError {
                Text(.uiDesignNumberError).font(Theme.fontSans(Theme.typeMeta)).foregroundStyle(Theme.danger)
                    .accessibilityAddTraits(.updatesFrequently)
            }
        }
        .padding(Theme.cardInset).foregroundStyle(Theme.text)
        .background(Theme.surface, in: .rect(cornerRadius: Theme.cornerRadius))
        .background(KeyboardOutsideTapBridge(isEnabled: focused) { focused = false }.allowsHitTesting(false))
        .onChange(of: editingID) { _, _ in focused = false }
        .onDisappear { focused = false }
    }
}
