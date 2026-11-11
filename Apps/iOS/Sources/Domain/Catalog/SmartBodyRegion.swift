import Foundation

/// Voluntary movement exclusions, not a diagnosis or a claim of clinical suitability.
nonisolated enum SmartBodyRegion: String, Codable, CaseIterable, Sendable {
    case foot, knee, hip, back, shoulder, elbow, wrist
    var label: String {
        switch self {
        case .foot: String(localized: .smartFoot)
        case .knee: String(localized: .smartKnee)
        case .hip: String(localized: .smartHip)
        case .back: String(localized: .smartBack)
        case .shoulder: String(localized: .smartShoulder)
        case .elbow: String(localized: .smartElbow)
        case .wrist: String(localized: .smartWrist)
        }
    }

    var exclusionSummary: String {
        switch self {
        case .foot: String(localized: .smartFootExclusions)
        case .knee: String(localized: .smartKneeExclusions)
        case .hip: String(localized: .smartHipExclusions)
        case .back: String(localized: .smartBackExclusions)
        case .shoulder: String(localized: .smartShoulderExclusions)
        case .elbow: String(localized: .smartElbowExclusions)
        case .wrist: String(localized: .smartWristExclusions)
        }
    }
}
