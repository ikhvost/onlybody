import Foundation

/// One broad preset or up to three individual muscle groups, shared by both selection screens.
nonisolated struct SmartTargetPolicy: Sendable {
    let presets: Set<String> = ["Full Body", "Upper", "Lower"]

    func isValid(_ targets: [String]) -> Bool {
        guard !targets.isEmpty, Set(targets).count == targets.count else { return false }
        if targets.contains(where: { presets.contains($0) }) {
            return targets.count == 1 && presets.contains(targets[0])
        }
        return targets.count <= 3 && targets.allSatisfy { ExerciseCatalog.allMuscles.contains($0) }
    }

    func canToggle(_ target: String, in targets: [String]) -> Bool {
        targets.contains(target) || presets.contains(target)
            || targets.filter { !presets.contains($0) }.count < 3
    }

    func toggling(_ target: String, in targets: [String]) -> [String] {
        if targets.contains(target) { return targets.filter { $0 != target } }
        guard ExerciseCatalog.sessionTargets.contains(target), canToggle(target, in: targets) else { return targets }
        if presets.contains(target) { return [target] }
        return targets.filter { !presets.contains($0) } + [target]
    }

    func muscles(for targets: [String]) -> Set<String> {
        Set(targets.flatMap { target -> [String] in
            switch target {
            case "Full Body": ExerciseCatalog.allMuscles
            case "Upper": ExerciseCatalog.upperMuscles
            case "Lower": ExerciseCatalog.lowerMuscles
            default: [target]
            }
        })
    }

    func gaps(targets: [String], exercises: [ExerciseSnapshot]) -> [String] {
        guard isValid(targets) else { return ["selection"] }
        let covered = Set(exercises.flatMap(\.primaryMuscles))
        let count = Set(exercises.map(\.name)).count
        switch targets {
        case ["Full Body"]:
            var gaps: [String] = []
            if covered.isDisjoint(with: ExerciseCatalog.upperMuscles) { gaps.append("Upper") }
            if covered.isDisjoint(with: ExerciseCatalog.lowerMuscles) { gaps.append("Lower") }
            if !covered.contains("Core") { gaps.append("Core") }
            if count < 3 { gaps.append("variety") }
            return gaps
        case ["Upper"], ["Lower"]:
            let region = muscles(for: targets)
            return covered.intersection(region).count >= 2 && count >= 2 ? [] : targets + ["variety"]
        default:
            return targets.filter { !covered.contains($0) }
        }
    }
}
