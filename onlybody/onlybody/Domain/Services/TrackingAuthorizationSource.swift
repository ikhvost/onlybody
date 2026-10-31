/// Supplies current permission and requests it only after an explicit user action.
@MainActor
protocol TrackingAuthorizationSource {
    var status: TrackingPermission { get }
    func request() async -> TrackingPermission
}
