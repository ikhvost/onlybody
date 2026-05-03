import Foundation
import SwiftData

@Model
final class Session {
    @Attribute(.unique) var id: UUID = UUID()
    var date: Date = Date.now
    var durationSeconds: Int = 0

    var workoutName: String = ""
    @Relationship(deleteRule: .cascade) var items: [SessionItem]? = nil

    init() {}
}
