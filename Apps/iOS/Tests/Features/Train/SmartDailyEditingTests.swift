import Foundation
import Testing
#if ONLYWEIGHTS
@testable import onlyweights
#else
@testable import onlybody
#endif

@MainActor
struct SmartDailyEditingTests {
    private func exercises() throws -> MockExerciseRepository {
        let repository = MockExerciseRepository()
        repository.stubbedAllExercises = try BundledExerciseCatalog.load(
            from: #require(Bundle.main.url(forResource: "default", withExtension: "store")))
        return repository
    }

    @Test func shortPlanNeedsExplicitAcceptanceAndPersistsItAcrossReopening() async throws {
        let repository = try exercises()
        let single = try #require(repository.stubbedAllExercises.first { $0.smartMetadata != nil && $0.difficulty == .beginner })
        repository.stubbedAllExercises = [single]
        let workouts = MockWorkoutRepository()
        let variants = MockSmartDailyVariantRepository()
        let model = SmartSelectionViewModel(workouts: workouts, exercises: repository, variants: variants,
            preferences: WorkoutPreferences(), targets: [single.primaryMuscles[0]], equipmentMode: .standardGym)
        await model.load()
        await model.preview()
        #expect(model.assessment.status == .shorter)
        #expect(!model.canStart)
        #expect(await model.save() == nil)
        await model.acceptShortPlan()
        let saved = try #require(await model.save())
        workouts.stubbedWorkouts = [saved]
        let reopened = SmartSelectionViewModel(workouts: workouts, exercises: repository, variants: variants,
            preferences: WorkoutPreferences(), workoutID: saved.id, opensPreview: true)
        await reopened.load()
        #expect(reopened.canStart)
        #expect(reopened.variant?.acceptedShortPlan == true)
    }

    @Test func reorderPersistsTodayAndLiveActivityUsesReviewedOrder() async throws {
        let repository = try exercises()
        let workouts = MockWorkoutRepository()
        let variants = MockSmartDailyVariantRepository()
        var now = Date(timeIntervalSince1970: 1_762_050_000)
        let model = SmartSelectionViewModel(workouts: workouts, exercises: repository, variants: variants,
            preferences: WorkoutPreferences(), targets: ["Full Body"], equipmentMode: .standardGym, now: { now })
        await model.load()
        await model.preview()
        await model.acceptShortPlan()
        let saved = try #require(await model.save())
        workouts.stubbedWorkouts = [saved]
        let first = try #require(model.variant?.items.first)
        let last = try #require(model.variant?.items.last)
        await model.moveMovement(last.id, to: first.id)
        await model.acceptShortPlan()
        #expect(model.variant?.items.first?.id == last.id)
        #expect(model.variant?.items.map(\.order) == Array(0..<saved.items.count))
        let reopened = SmartSelectionViewModel(workouts: workouts, exercises: repository, variants: variants,
            preferences: WorkoutPreferences(), workoutID: saved.id, opensPreview: true, now: { now })
        await reopened.load()
        #expect(reopened.variant?.items == model.variant?.items)
        let reviewed = try #require(await reopened.save())
        let activity = MockWorkoutLiveActivity()
        let time = ManualWorkoutTimeSource()
        let active = ActiveWorkoutViewModel(workouts: workouts, sessions: MockSessionRepository(), workoutId: saved.id,
            time: time, reviewedWorkout: reviewed, liveActivity: activity)
        await active.load()
        #expect(activity.states.last?.exerciseName == last.exercise?.displayName)
        active.markSetDone()
        #expect(activity.states.last?.restDeadline == time.now.addingTimeInterval(TimeInterval(last.restSeconds)))
        #expect(activity.states.last?.setNumber == 2)
        now = now.addingTimeInterval(86_400)
        #expect(!reopened.canStart)
        await reopened.refreshDay()
        #expect(reopened.variant?.localDay != model.variant?.localDay)
        #expect(active.items == reviewed.items)
        active.cleanup()
    }

    @Test func cachedLegacyPlanIsRecheckedWithoutReplacingItsItems() async throws {
        let repository = try exercises()
        let first = try #require(repository.stubbedAllExercises.first { $0.smartMetadata != nil })
        let configuration = SmartWorkoutConfiguration(targetMuscleGroups: ["Upper", "Chest"], equipmentMode: .standardGym)
        let settings = SmartWorkoutSettings(configuration: configuration)
        let workout = WorkoutSnapshot(smartSettings: settings)
        let variants = MockSmartDailyVariantRepository()
        let now = Date()
        let daily = SmartDailyVariant(workoutID: workout.id, localDay: SmartPlanningClock().localDay(at: now),
            settingsRevision: settings.revision, items: [WorkoutItemSnapshot(exercise: first)], estimatedSeconds: 1800,
            uncoveredNeeds: [], createdAt: now, acceptedShortPlan: true)
        try await variants.save(daily)
        let workouts = MockWorkoutRepository()
        workouts.stubbedWorkouts = [workout]
        let model = SmartSelectionViewModel(workouts: workouts, exercises: repository, variants: variants,
            preferences: WorkoutPreferences(), workoutID: workout.id, opensPreview: true, now: { now })
        await model.load()
        #expect(model.configuration.targetMuscleGroups == ["Upper", "Chest"])
        #expect(model.variant?.items == daily.items)
        #expect(!model.canStart)
        #expect(await model.save() == nil)
        #expect(!model.gaps.isEmpty)
    }

    @Test func oldDailyPayloadDecodesWithoutShortPlanAcceptance() throws {
        let daily = SmartDailyVariant(workoutID: UUID(), localDay: "2026-11-09", settingsRevision: UUID(),
            items: [], estimatedSeconds: 100, uncoveredNeeds: [], createdAt: Date())
        let data = try JSONEncoder().encode(daily)
        #expect(try #require(String(data: data, encoding: .utf8)).contains("acceptedShortPlan") == false)
        #expect(try JSONDecoder().decode(SmartDailyVariant.self, from: data).acceptedShortPlan == nil)
    }
}
