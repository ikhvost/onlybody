/// The editable fields used to decide whether leaving the flow needs confirmation.
struct SmartSelectionDraft: Equatable {
    let configuration: SmartWorkoutConfiguration
    let name: String
    let scheduledDays: Set<String>
}
