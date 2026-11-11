import Foundation

/// Storage boundary for per-workout, local-day, settings-revision variants.
@MainActor
protocol SmartDailyVariantRepository: Sendable {
    func variant(workoutID: UUID, localDay: String, settingsRevision: UUID) async throws -> SmartDailyVariant?
    func latestVariant(workoutID: UUID) async throws -> SmartDailyVariant?
    /// Atomically replaces a variant; failures leave the previous value intact.
    func save(_ variant: SmartDailyVariant) async throws
}
