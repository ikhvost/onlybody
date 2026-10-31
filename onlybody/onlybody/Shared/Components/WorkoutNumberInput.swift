import SwiftUI

/// Large numeric editing surface; validation and committed values belong to the owning screen model.
struct WorkoutNumberInput: View {
    let title: String
    let identifier: String
    @Binding var text: String
    var isDecimal = false
    let hasError: Bool
    let canDecrease: Bool
    let onDecrease: () -> Void
    let onIncrease: () -> Void
    @FocusState private var focused: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: Theme.space12) {
            Text(title).font(Theme.fontSans(Theme.typeMeta)).foregroundStyle(Theme.text2)
            HStack(spacing: Theme.space12) {
                Button(action: onDecrease) {
                    Text("−").font(Theme.fontSans(Theme.typeCard))
                        .frame(width: Theme.stepSize, height: Theme.stepSize)
                        .background(Theme.surface2, in: .rect(cornerRadius: Theme.buttonRadius))
                }
                .disabled(!canDecrease || hasError).buttonStyle(.plain)
                .accessibilityLabel(String(localized: .uiDecrease(title)))
                .accessibilityIdentifier("stepper.\(identifier).decrease")
                TextField(title, text: $text)
                    .keyboardType(isDecimal ? .decimalPad : .numberPad).focused($focused)
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
                .disabled(hasError).buttonStyle(.plain)
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
        .toolbar {
            if focused {
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button(String(localized: .uiDone)) { focused = false }.disabled(hasError)
                }
            }
        }
    }
}
