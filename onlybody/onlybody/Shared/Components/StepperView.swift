import SwiftUI

struct StepperView: View {
    let label: String
    let valueText: String
    let canDecrement: Bool
    let onIncrement: () -> Void
    let onDecrement: () -> Void

    init(
        label: String,
        value: Int,
        step: Int,
        minValue: Int,
        format: (Int) -> String,
        onIncrement: @escaping () -> Void,
        onDecrement: @escaping () -> Void
    ) {
        self.label = label
        valueText = format(value)
        canDecrement = value - step >= minValue
        self.onIncrement = onIncrement
        self.onDecrement = onDecrement
    }

    init(
        label: String,
        valueText: String,
        canDecrement: Bool,
        onIncrement: @escaping () -> Void,
        onDecrement: @escaping () -> Void
    ) {
        self.label = label
        self.valueText = valueText
        self.canDecrement = canDecrement
        self.onIncrement = onIncrement
        self.onDecrement = onDecrement
    }

    var body: some View {
        VStack(spacing: 6) {
            MonoLabel(text: label, size: 9, color: Theme.text3, tracking: 0.5)

            HStack(spacing: 4) {
                Button {
                    if canDecrement {
                        onDecrement()
                    }
                } label: {
                    Text("−")
                        .font(Theme.fontMono(14, .medium))
                        .foregroundStyle(canDecrement ? Theme.text : Theme.text3)
                        .frame(width: 24, height: 24)
                        .background(Theme.surface2)
                        .clipShape(.rect(cornerRadius: Theme.chipCornerRadius))
                        .overlay {
                            RoundedRectangle(cornerRadius: Theme.chipCornerRadius)
                                .stroke(Theme.border2, lineWidth: 1)
                        }
                }
                .disabled(!canDecrement)
                .buttonStyle(.plain)

                Text(valueText)
                    .font(Theme.fontMono(14, .bold))
                    .foregroundStyle(Theme.text)
                    .frame(maxWidth: .infinity)

                Button {
                    onIncrement()
                } label: {
                    Text("+")
                        .font(Theme.fontMono(14, .medium))
                        .foregroundStyle(Theme.accentDark)
                        .frame(width: 24, height: 24)
                        .background(Theme.accent)
                        .clipShape(.rect(cornerRadius: Theme.chipCornerRadius))
                }
                .buttonStyle(.plain)
            }
        }
        .frame(maxWidth: .infinity)
    }
}
