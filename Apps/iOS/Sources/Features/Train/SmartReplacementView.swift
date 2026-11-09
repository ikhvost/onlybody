import SwiftUI

struct SmartReplacementView: View {
    @State var viewModel: SmartReplacementViewModel
    @State private var picker: ExercisePickerViewModel
    let makeMovement: (ExerciseSnapshot) -> MovementDetailViewModel
    let onReplace: (ExerciseSnapshot) -> Void
    let onExclude: () async -> Bool
    @Environment(\.dismiss) private var dismiss
    @State private var confirmExclusion = false
    @State private var isSaving = false
    @State private var saveFailed = false

    init(viewModel: SmartReplacementViewModel, makeMovement: @escaping (ExerciseSnapshot) -> MovementDetailViewModel,
         onReplace: @escaping (ExerciseSnapshot) -> Void, onExclude: @escaping () async -> Bool) {
        _viewModel = State(initialValue: viewModel)
        _picker = State(initialValue: ExercisePickerViewModel(exercises: viewModel.alternatives))
        self.makeMovement = makeMovement
        self.onReplace = onReplace
        self.onExclude = onExclude
    }

    var body: some View {
        ExercisePickerView(viewModel: picker, makeMovement: makeMovement, title: String(localized: .uiWorkoutReplace),
                           emptyMessage: viewModel.alternatives.isEmpty
                            ? String(localized: .smartNoAlternatives) : String(localized: .uiNoMovementsFound),
                           isDismissDisabled: isSaving || confirmExclusion, options: {
            VStack(alignment: .leading, spacing: Theme.space8) {
                if saveFailed { Text(.uiCouldNotSaveSession).foregroundStyle(Theme.danger) }
                HStack(spacing: Theme.space12) {
                    Text(.smartLocal).font(Theme.fontSans(Theme.typeMeta)).foregroundStyle(Theme.text2)
                    Spacer(minLength: Theme.space0)
                    Menu(String(localized: .smartSettings)) {
                        if viewModel.hasEquipment {
                            Toggle(String(localized: .smartUnavailable), isOn: Binding(
                                get: { viewModel.equipmentUnavailable == true },
                                set: { viewModel.equipmentUnavailable = $0 }))
                        }
                        Button(String(localized: .smartPermanent), role: .destructive) { confirmExclusion = true }
                    }.frame(minWidth: Theme.touchSize, minHeight: Theme.touchSize)
                        .accessibilityIdentifier("smartReplacement.options")
                }
            }.padding(.horizontal, Theme.horizontalPadding)
        }, onAdd: onReplace)
        .disabled(isSaving)
        .interactiveDismissDisabled(isSaving)
        .onChange(of: viewModel.equipmentUnavailable) { _, _ in picker.exercises = viewModel.alternatives }
        .alert(String(localized: .smartPermanent), isPresented: $confirmExclusion) {
            Button(String(localized: .smartExclude), role: .destructive) {
                Task {
                    isSaving = true
                    if await onExclude() { dismiss() } else { saveFailed = true }
                    isSaving = false
                }
            }
            Button(String(localized: .uiCancel), role: .cancel) {}
        } message: { Text(.smartPermanentHint) }
    }
}
