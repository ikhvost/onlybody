/// Counts each planned set once for each distinct primary muscle in its exercise.
nonisolated struct WorkoutMuscleSummaryCalculator {
    func calculate(items: [WorkoutItemSnapshot]) -> WorkoutMuscleSummary {
        var counts: [String: Int] = [:]
        var secondary: Set<String> = []
        var missing = 0
        var total = 0
        for item in items {
            let sets = max(0, item.sets)
            total += sets
            guard let exercise = item.exercise else { missing += 1; continue }
            for muscle in Set(exercise.primaryMuscles) where sets > 0 { counts[muscle, default: 0] += sets }
            secondary.formUnion(exercise.supportingMuscles)
        }
        let ranked = counts.map { WorkoutMuscleCount(muscle: $0.key, sets: $0.value) }.sorted {
            $0.sets == $1.sets ? $0.muscle < $1.muscle : $0.sets > $1.sets
        }
        return WorkoutMuscleSummary(ranked: ranked, secondary: secondary.filter { counts[$0] == nil }.sorted(),
                                    missingExercises: missing, totalSets: total)
    }
}
