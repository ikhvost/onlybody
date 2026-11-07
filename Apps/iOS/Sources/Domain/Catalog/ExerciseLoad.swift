import Foundation

/// Legacy explicit exclusions retained when older Smart settings are opened.
nonisolated enum ExerciseLoad: String, Codable, CaseIterable, Identifiable, Sendable {
    case jumping, palmSupport, kneeSupport, overhead, standing
    var id: String { rawValue }
    var label: String {
        switch self {
        case .jumping: String(localized: .smartLoadJumping)
        case .palmSupport: String(localized: .smartLoadPalms)
        case .kneeSupport: String(localized: .smartLoadKnees)
        case .overhead: String(localized: .smartLoadOverhead)
        case .standing: String(localized: .smartLoadStanding)
        }
    }
}
