import Foundation

nonisolated enum SmartNeedLabel {
    static func label(_ need: String) -> String {
        switch need {
        case "movement:push": String(localized: .smartPush)
        case "movement:pull": String(localized: .smartPull)
        case "movement:squat": String(localized: .smartSquat)
        case "movement:hinge": String(localized: .smartHinge)
        case "movement:core": String(localized: .smartCore)
        case "selection": String(localized: .smartInvalidTargets)
        case "variety": String(localized: .smartInsufficientVariety)
        case "constraints": String(localized: .smartConstraintMismatch)
        case "time": String(localized: .smartDuration)
        default: CatalogLocalization.label(need)
        }
    }
}
