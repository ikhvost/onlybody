import Testing
#if ONLYWEIGHTS
@testable import onlyweights
#else
@testable import onlybody
#endif

@MainActor
struct ProductConfigurationTests {
    @Test func compositionPassesBrandToTrainScreen() {
        for configuration in [AppConfiguration.onlyBody, .onlyWeights] {
            let composition = AppComposition(
                configuration: configuration, exercises: MockExerciseRepository(),
                workouts: MockWorkoutRepository(), sessions: MockSessionRepository()
            )
            #expect(composition.train().appName == configuration.displayName)
        }
    }

    @Test func selectedProductMatchesBuild() {
        #if ONLYWEIGHTS
        #expect(AppConfiguration.current.displayName == "OnlyWeights")
        #expect(AppConfiguration.current.workoutFallback == .matchingCatalog)
        #else
        #expect(AppConfiguration.current.displayName == "OnlyBody")
        #expect(AppConfiguration.current.workoutFallback == .bodyweight)
        #endif
    }

    @Test func gymKeepsSingleEquipmentMovementWhileBodyweightFallbackRemainsUnchanged() {
        let exercise = ExerciseSnapshot(name: "Test machine", primaryMuscle: "Quads", equipment: ["Machine"])
        let configuration = SmartWorkoutConfiguration(targetMuscleGroups: ["Quads"])
        let gym = SmartWorkoutGenerator(fallbackPolicy: .matchingCatalog)
        let body = SmartWorkoutGenerator(fallbackPolicy: .bodyweight)
        #expect(gym.generate(config: configuration, from: [exercise]).map(\.exercise.id) == [exercise.id])
        #expect(body.generate(config: configuration, from: [exercise]).isEmpty)
        #expect(gym.generate(config: configuration, from: []).isEmpty)
        let unrelated = ExerciseSnapshot(name: "Other machine", primaryMuscle: "Chest", equipment: ["Machine"])
        #expect(gym.generate(config: configuration, from: [unrelated]).isEmpty)
    }

    @Test func builderReceivesProductGenerationPolicy() async {
        let exercises = MockExerciseRepository()
        exercises.stubbedAllExercises = [ExerciseSnapshot(name: "Test machine", primaryMuscle: "Quads", equipment: ["Machine"])]
        let composition = AppComposition(
            configuration: .onlyWeights, exercises: exercises,
            workouts: MockWorkoutRepository(), sessions: MockSessionRepository()
        )
        let builder = composition.builder(workout: nil, targets: ["Quads"])
        await builder.loadExercises()
        #expect(await builder.save())
        #expect(builder.movements.count == 1)
    }
}
