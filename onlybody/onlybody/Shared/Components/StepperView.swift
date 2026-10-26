import SwiftUI

struct StepperView: View {
    let identifier: String
    let label: String
    let valueText: String
    let canDecrement: Bool
    let onIncrement: () -> Void
    let onDecrement: () -> Void

    init(
        label: String,
        identifier: String? = nil,
        value: Int,
        step: Int,
        minValue: Int,
        format: (Int) -> String,
        onIncrement: @escaping () -> Void,
        onDecrement: @escaping () -> Void
    ) {
        self.label = label
        self.identifier = identifier ?? label
        valueText = format(value)
        canDecrement = value - step >= minValue
        self.onIncrement = onIncrement
        self.onDecrement = onDecrement
    }

    init(
        label: String,
        identifier: String? = nil,
        valueText: String,
        canDecrement: Bool,
        onIncrement: @escaping () -> Void,
        onDecrement: @escaping () -> Void
    ) {
        self.label = label
        self.identifier = identifier ?? label
        self.valueText = valueText
        self.canDecrement = canDecrement
        self.onIncrement = onIncrement
        self.onDecrement = onDecrement
    }

    var body: some View {
        VStack(spacing: Theme.space6) {
            MonoLabel(text: label, size: Theme.type10, color: Theme.text3, tracking: 0.5)

            HStack(spacing: Theme.space4) {
                Button {
                    if canDecrement {
                        onDecrement()
                    }
                } label: {
                    Text("−")
                        .font(Theme.fontMono(Theme.type14, .medium))
                        .foregroundStyle(canDecrement ? Theme.text : Theme.text3)
                        .frame(width: 32, height: 32)
                        .background(Theme.surface2)
                        .clipShape(.rect(cornerRadius: Theme.chipCornerRadius))
                        .overlay {
                            RoundedRectangle(cornerRadius: Theme.chipCornerRadius)
                                .stroke(Theme.border2, lineWidth: 1)
                        }
                }
                .accessibilityLabel(String(localized: .uiDecrease(label)))
                .accessibilityIdentifier("stepper.\(identifier).decrease")
                .disabled(!canDecrement)
                .buttonStyle(.plain)

                Text(valueText)
                    .accessibilityIdentifier("stepper.\(identifier).value")
                    .font(Theme.fontMono(Theme.type14, .bold))
                    .foregroundStyle(Theme.text)
                    .frame(maxWidth: .infinity)

                Button {
                    onIncrement()
                } label: {
                    Text("+")
                        .font(Theme.fontMono(Theme.type14, .medium))
                        .foregroundStyle(Theme.accentDark)
                        .frame(width: 32, height: 32)
                        .background(Theme.accent)
                        .clipShape(.rect(cornerRadius: Theme.chipCornerRadius))
                }
                .accessibilityLabel(String(localized: .uiIncrease(label)))
                .accessibilityIdentifier("stepper.\(identifier).increase")
                .buttonStyle(.plain)
            }
        }
        .frame(maxWidth: .infinity)
    }
}
