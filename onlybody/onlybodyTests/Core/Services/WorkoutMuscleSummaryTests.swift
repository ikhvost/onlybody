import Foundation
import Testing
#if ONLYWEIGHTS
@testable import onlyweights
#else
@testable import onlybody
#endif

struct WorkoutMuscleSummaryTests {
    @Test func countsMultiplePrimaryGroupsAndRepeatedExercisesWithoutDoubleCountingSecondary() {
        let arms = ExerciseSnapshot(name: "Fixture arms", primaryMuscle: "Arms", secondaryMuscles: ["Chest", "Chest", "Biceps"])
        let chest = ExerciseSnapshot(name: "Fixture chest", primaryMuscle: "Chest", secondaryMuscles: ["Core"])
        let items = [WorkoutItemSnapshot(sets: 3, exercise: arms), WorkoutItemSnapshot(sets: 2, exercise: arms),
                     WorkoutItemSnapshot(sets: 5, exercise: chest), WorkoutItemSnapshot(sets: 2)]
        let result = WorkoutMuscleSummaryCalculator().calculate(items: items)
        #expect(result.totalSets == 12)
        #expect(result.missingExercises == 1)
        #expect(result.ranked.count == 4)
        #expect(result.ranked.allSatisfy { $0.sets == 5 })
        #expect(Set(result.focus) == Set(["Biceps", "Triceps", "Forearms", "Chest"]))
        #expect(result.secondary == ["Core"])
        #expect(result.diagram.primary.count == 4)
    }

    @Test func emptyOrNonpositiveSetsDoNotInventFocus() {
        let calculator = WorkoutMuscleSummaryCalculator()
        #expect(calculator.calculate(items: []).ranked.isEmpty)
        let item = WorkoutItemSnapshot(sets: 0, exercise: ExerciseSnapshot(name: "Fixture", primaryMuscle: "Chest"))
        #expect(calculator.calculate(items: [item]).focus.isEmpty)
    }
}
