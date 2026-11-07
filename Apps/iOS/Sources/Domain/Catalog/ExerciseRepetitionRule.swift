import Foundation

/// A side-based target is performed on both sides; a cycle includes both alternating sides.
nonisolated enum ExerciseRepetitionRule: String, Codable, Sendable {
    case total, perSide, fullCycle

    var multiplier: Int { self == .perSide ? 2 : 1 }
    var label: String {
        switch self {
        case .total: ""
        case .perSide: String(localized: .smartPerSide)
        case .fullCycle: String(localized: .smartFullCycles)
        }
    }
}
