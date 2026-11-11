import Foundation
#if ONLYWEIGHTS
@testable import onlyweights
#else
@testable import onlybody
#endif

@MainActor
final class MockSmartDailyVariantRepository: SmartDailyVariantRepository {
    var variants: [SmartDailyVariant] = []
    var shouldThrow = false
    var writes: [SmartDailyVariant] = []
    func variant(workoutID: UUID, localDay: String, settingsRevision: UUID) async throws -> SmartDailyVariant? {
        if shouldThrow { throw TestError.expectedFailure }
        return variants.first { $0.workoutID == workoutID && $0.localDay == localDay && $0.settingsRevision == settingsRevision }
    }
    func latestVariant(workoutID: UUID) async throws -> SmartDailyVariant? {
        if shouldThrow { throw TestError.expectedFailure }
        return variants.filter { $0.workoutID == workoutID }.max { $0.createdAt < $1.createdAt }
    }
    func save(_ variant: SmartDailyVariant) async throws {
        if shouldThrow { throw TestError.expectedFailure }
        writes.append(variant)
        variants.removeAll { $0.id == variant.id }
        variants.append(variant)
    }
}
