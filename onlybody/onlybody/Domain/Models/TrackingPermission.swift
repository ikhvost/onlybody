/// App-level tracking authorization, independent of the platform permission framework.
nonisolated enum TrackingPermission: Sendable, Equatable {
    case notDetermined
    case authorized
    case denied
    case restricted
}
