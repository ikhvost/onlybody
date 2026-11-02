import SwiftUI

struct WorkoutTimingPicker: View {
    let title: String
    let unit: String
    let options: [Int]
    @State var selection: Int
    let onSelect: (Int) -> Void
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: Theme.space12) {
            HStack {
                Button(String(localized: .uiCancel)) { dismiss() }
                    .foregroundStyle(Theme.text2)
                Spacer()
                Text(title).foregroundStyle(Theme.text)
                Spacer()
                Button(String(localized: .uiDone)) { onSelect(selection); dismiss() }
                    .foregroundStyle(Theme.accent)
                    .accessibilityIdentifier("timing.done")
            }
            .font(Theme.fontSans(Theme.type15, .semibold))
            Picker(title, selection: $selection) {
                ForEach(Array(Set(options + [selection])).sorted(), id: \.self) { value in
                    Text("\(value) \(unit)")
                        .font(Theme.fontMono(Theme.type20))
                        .tag(value)
                }
            }
            .pickerStyle(.wheel)
            .frame(height: Theme.timingWheelHeight)
            .accessibilityIdentifier("timing.wheel")
        }
        .padding(Theme.horizontalPadding)
        .presentationDetents([.height(Theme.timingPickerHeight)])
        .presentationDragIndicator(.visible)
        .presentationBackground(Theme.surface)
        .preferredColorScheme(.dark)
    }
}
