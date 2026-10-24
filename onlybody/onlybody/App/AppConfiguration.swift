/// Immutable product choices assembled at the application boundary.
nonisolated struct AppConfiguration: Sendable {
    let displayName: String
    let workoutFallback: WorkoutFallbackPolicy

    static let onlyBody = AppConfiguration(displayName: "OnlyBody", workoutFallback: .bodyweight)
    static let onlyWeights = AppConfiguration(displayName: "OnlyWeights", workoutFallback: .matchingCatalog)

    static var current: AppConfiguration {
        #if ONLYWEIGHTS
        .onlyWeights
        #else
        .onlyBody
        #endif
    }
}
