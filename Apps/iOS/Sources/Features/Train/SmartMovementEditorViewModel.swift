import Foundation
import Observation

/// A detached sheet draft. Cancel and swipe-to-dismiss never change today's plan.
@MainActor
@Observable
final class SmartMovementEditorViewModel {
    private(set) var item: WorkoutItemSnapshot
    private var inputs: [String: String] = [:]
    private var errors: Set<String> = []
    var isSaving = false
    var saveFailed = false
    var hasInvalidNumbers: Bool { !errors.isEmpty }
    var name: String { item.exercise?.displayName ?? String(localized: .uiDesignUnknownExercise) }

    init(item: WorkoutItemSnapshot) { self.item = item }

    func title(_ field: String) -> String {
        switch field {
        case "Sets": String(localized: .uiSets)
        case "Reps": String(localized: .uiReps)
        default: String(localized: .uiRest)
        }
    }

    func value(_ field: String) -> Int {
        switch field {
        case "Sets": item.sets
        case "Reps": item.targetReps
        default: item.restSeconds
        }
    }

    func text(_ field: String) -> String { inputs[field] ?? String(value(field)) }
    func hasError(_ field: String) -> Bool { errors.contains(field) }
    func canDecrease(_ field: String) -> Bool { value(field) > (field == "Rest" ? 0 : 1) }

    func enter(_ text: String, field: String) {
        inputs[field] = text
        guard let number = WorkoutNumberParser().integer(text, minimum: field == "Rest" ? 0 : 1) else {
            errors.insert(field)
            return
        }
        errors.remove(field)
        switch field {
        case "Sets": item.sets = number
        case "Reps": item.targetReps = number
        default: item.restSeconds = number
        }
    }

    func step(_ field: String, increasing: Bool) {
        let step = field == "Rest" ? 15 : 1
        let next = max(field == "Rest" ? 0 : 1, min(Int(Int32.max), value(field) + (increasing ? step : -step)))
        enter(String(next), field: field)
    }
}
