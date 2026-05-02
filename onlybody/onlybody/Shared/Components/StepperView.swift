import SwiftUI

struct StepperView: View {
    let label: String
    let value: Int
    let step: Int
    let minValue: Int
    let format: (Int) -> String
    let onIncrement: () -> Void
    let onDecrement: () -> Void

    private var canDecrement: Bool {
        value - step >= minValue
    }

    var body: some View {
        VStack(spacing: Theme.space6) {
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

                Text(format(value))
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
