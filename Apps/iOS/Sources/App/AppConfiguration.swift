import Foundation

/// Immutable product choices assembled at the application boundary.
nonisolated struct AppConfiguration: Sendable {
    let displayName: String
    var alwaysShowsWeight = false
    let workoutFallback: WorkoutFallbackPolicy
    let appStoreReviewURL: URL?

    static let onlyBody = AppConfiguration(
        displayName: "OnlyBody",
        workoutFallback: .bodyweight,
        appStoreReviewURL: URL(string: "https://apps.apple.com/app/id6827692702?action=write-review")
    )
    static let onlyWeights = AppConfiguration(
        displayName: "OnlyWeights",
        alwaysShowsWeight: true,
        workoutFallback: .matchingCatalog,
        appStoreReviewURL: URL(string: "https://apps.apple.com/app/id6827693301?action=write-review")
    )

    static var current: AppConfiguration {
        #if ONLYWEIGHTS
        .onlyWeights
        #else
        .onlyBody
        #endif
    }
}
