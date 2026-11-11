import Foundation
import SwiftData

@Model
final class SmartDailyVariantRecord {
    @Attribute(.unique) var key: String = ""
    var workoutID: UUID = UUID()
    var localDay: String = ""
    var settingsRevision: UUID = UUID()
    var createdAt: Date = Date()
    var payload: Data = Data()
    init() {}
}
