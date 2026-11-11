import Foundation
import SwiftData

/// Additive schema: the identities and stored properties of legacy entities remain unchanged.
@Model
final class SmartWorkoutSettingsRecord {
    @Attribute(.unique) var workoutID: UUID = UUID()
    var payload: Data = Data()
    init() {}
}
