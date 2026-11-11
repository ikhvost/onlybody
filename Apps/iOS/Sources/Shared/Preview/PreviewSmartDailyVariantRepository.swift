#if DEBUG
import Foundation

/// Fixed fixtures; previews never open a persistent store.
struct PreviewSmartDailyVariantRepository: SmartDailyVariantRepository {
    var variants: [SmartDailyVariant] = []
    func variant(workoutID: UUID, localDay: String, settingsRevision: UUID) async throws -> SmartDailyVariant? {
        variants.first { $0.workoutID == workoutID && $0.localDay == localDay && $0.settingsRevision == settingsRevision }
    }
    func latestVariant(workoutID: UUID) async throws -> SmartDailyVariant? {
        variants.filter { $0.workoutID == workoutID }.max { $0.createdAt < $1.createdAt }
    }
    func save(_ variant: SmartDailyVariant) async throws {}
}
#endif
