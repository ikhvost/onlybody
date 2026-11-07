import Foundation

/// Planning patterns; these describe movement, not medical suitability.
nonisolated enum SmartMovement: String, Codable, CaseIterable, Sendable {
    case push, pull, squat, hinge, core, curl, `extension`, raise, abduction, adduction, calf, locomotion
}
