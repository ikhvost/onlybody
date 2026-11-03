import SwiftUI

struct ActiveWorkoutSetRow: View {
    let viewModel: ActiveWorkoutViewModel
    let setID: WorkoutSetID
    var focusedField: FocusState<WorkoutSetField?>.Binding
    let onDismissKeyboard: () -> Void

    var body: some View {
        HStack(spacing: Theme.space10) {
            Text(setID.index + 1, format: .number)
                .font(Theme.fontMono(Theme.typeMeta)).foregroundStyle(Theme.text2)
                .frame(width: Theme.touchSize)
            TextField(String(localized: .uiReps), text: Binding(
                get: { viewModel.repsText(for: setID) }, set: { viewModel.enterReps($0, for: setID) }
            ))
            .frame(maxWidth: .infinity, minHeight: Theme.stepSize)
            .background(Theme.surface, in: .rect(cornerRadius: Theme.buttonRadius))
            .overlay { RoundedRectangle(cornerRadius: Theme.buttonRadius)
                    .stroke(viewModel.row(setID).invalidReps ? Theme.danger : Theme.border2) }
            .keyboardType(.numberPad).focused(focusedField, equals: .reps(setID))
            .accessibilityLabel(String(localized: .uiReps) + " \(setID.index + 1)")
            .accessibilityIdentifier("active.set.\(setID.index).reps")
            if viewModel.showsWeight {
                TextField(viewModel.weightUnitSymbol, text: Binding(
                    get: { viewModel.weightText(for: setID) }, set: { text in
                        guard focusedField.wrappedValue == .weight(setID) else { return }
                        viewModel.enterWeight(text, for: setID)
                    }
                ))
                .frame(maxWidth: .infinity, minHeight: Theme.stepSize)
                .background(Theme.surface, in: .rect(cornerRadius: Theme.buttonRadius))
                .overlay { RoundedRectangle(cornerRadius: Theme.buttonRadius)
                        .stroke(viewModel.row(setID).invalidWeight ? Theme.danger : Theme.border2) }
                .keyboardType(.decimalPad).focused(focusedField, equals: .weight(setID))
                .accessibilityLabel(viewModel.weightUnitSymbol + " \(setID.index + 1)")
                .accessibilityIdentifier("active.set.\(setID.index).weight")
            }
            Button {
                onDismissKeyboard()
                viewModel.toggleSet(setID)
            } label: {
                CheckIcon(color: viewModel.row(setID).isDone ? Theme.accentDark : Theme.text3)
                    .frame(width: Theme.stepSize, height: Theme.stepSize)
                    .background(viewModel.row(setID).isDone ? Theme.accent : Theme.surface2,
                                in: .circle)
                    .overlay { Circle().stroke(Theme.border2) }
            }
            .accessibilityLabel(String(localized: viewModel.row(setID).isDone ? .uiWorkoutUncheckSet : .uiWorkoutCheckSet)
                                + " \(setID.index + 1)")
            .accessibilityValue(String(localized: viewModel.row(setID).isDone ? .uiWorkoutCompleted : .uiWorkoutUpcoming))
            .accessibilityIdentifier("active.set.\(setID.index).done")
            .disabled(!viewModel.hasStarted || viewModel.hasInvalidNumbers)
            .buttonStyle(PressableButtonStyle(animates: false))
        }
        .font(Theme.fontMono(Theme.typeCard)).multilineTextAlignment(.center)
        .textFieldStyle(.plain)
        .frame(minHeight: Theme.stepSize)
        .padding(.vertical, Theme.space12)
        .overlay(alignment: .bottom) { Rectangle().fill(Theme.border).frame(height: Theme.dividerThickness) }
    }
}
