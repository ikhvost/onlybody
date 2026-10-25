import Foundation
import Testing
#if ONLYWEIGHTS
@testable import onlyweights
#else
@testable import onlybody
#endif

@MainActor
struct WorkoutWeightUnitTests {
    @Test(arguments: WeightUnit.allCases)
    func enteredWeightsSavePerSetInKilograms(unit: WeightUnit) async throws {
        let repository = MockWorkoutRepository()
        let sessions = MockSessionRepository()
        let workout = WorkoutSnapshot(items: [WorkoutItemSnapshot(sets: 2, exercise: ExerciseSnapshot(name: "Squats"))])
        repository.stubbedWorkouts = [workout]
        let preferences = WorkoutPreferences(weightUnit: unit)
        let model = ActiveWorkoutViewModel(
            workouts: repository, sessions: sessions, workoutId: workout.id,
            time: ManualWorkoutTimeSource(), preferences: preferences
        )
        defer { model.cleanup() }
        await model.load()
        model.decrementWeight()
        #expect(model.currentWeight == 0)
        model.incrementWeight()
        #expect(abs(model.displayedWeight - unit.step) < 0.000000001)
        #expect(model.weightUnitSymbol == unit.rawValue)
        model.markSetDone()
        model.restTimer.skip()
        model.incrementWeight()
        model.markSetDone()
        await model.saveTask?.value
        let saved = try #require(sessions.savedSessions.first?.items.first)
        let weights = try #require(saved.setWeightsKg)
        #expect(weights.count == 2)
        #expect(abs(weights[0] - unit.kilograms(from: unit.step)) < 0.000000001)
        #expect(abs(weights[1] - unit.kilograms(from: unit.step * 2)) < 0.000000001)
        #expect(saved.weightKg == weights[1])
        #expect(sessions.savedSessions.count == 1)
    }

    @Test func unitChangesOnlyPresentationAndLeaveCompletedSetsUntouched() async {
        let preferences = WorkoutPreferences()
        let model = ActiveWorkoutViewModel(
            workouts: MockWorkoutRepository(), sessions: MockSessionRepository(), workoutId: UUID(),
            time: ManualWorkoutTimeSource(), preferences: preferences
        )
        model.items = [WorkoutItemSnapshot(sets: 2)]
        model.weights[0] = 20
        model.markSetDone()
        defer { model.cleanup() }
        let before = model.buildSessionItems().map(\.setWeightsKg)
        preferences.weightUnit = .pounds
        #expect(abs(model.displayedWeight - 44.092452437) < 0.000000001)
        #expect(model.currentWeight == 20)
        #expect(model.buildSessionItems().map(\.setWeightsKg) == before)
        preferences.weightUnit = .kilograms
        #expect(model.displayedWeight == 20)
        #expect(model.buildSessionItems().map(\.setWeightsKg) == before)
    }
}
