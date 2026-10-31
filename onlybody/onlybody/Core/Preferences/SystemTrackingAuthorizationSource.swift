import AppTrackingTransparency
import UIKit

/// Uses the system permission; a local YouTube consent never substitutes for ATT.
@MainActor
struct SystemTrackingAuthorizationSource: TrackingAuthorizationSource {
    var status: TrackingPermission {
        switch ATTrackingManager.trackingAuthorizationStatus {
        case .authorized: .authorized
        case .denied: .denied
        case .restricted: .restricted
        case .notDetermined: .notDetermined
        @unknown default: .restricted
        }
    }

    func request() async -> TrackingPermission {
        guard status == .notDetermined, UIApplication.shared.applicationState == .active else { return status }
        _ = await ATTrackingManager.requestTrackingAuthorization()
        return status
    }
}
