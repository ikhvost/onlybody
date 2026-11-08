import Foundation
import OSLog

/// Gives each rest deadline one owner for its cue, including across foreground transitions.
@MainActor
final class WorkoutRestAlerts {
    static let requestPrefix = "workout.rest."

    private let time: any WorkoutTimeSource
    private let notifications: (any WorkoutRestNotificationClient)?
    private let isEnabled: @MainActor () -> Bool
    private let isForeground: @MainActor () -> Bool
    private let playCue: @MainActor () -> Void
    private let stopCue: @MainActor () -> Void
    private let logger = Logger(subsystem: "WorkoutNotifications", category: "Rest")
    private var foregroundSince = Date.distantPast
    private var deadline: Date?
    private(set) var notificationID: String?
    private var hasDeliveredCue = false

    init(
        time: any WorkoutTimeSource = SystemWorkoutTimeSource(),
        notifications: (any WorkoutRestNotificationClient)? = nil,
        isEnabled: @escaping @MainActor () -> Bool,
        isForeground: @escaping @MainActor () -> Bool = { true },
        playCue: @escaping @MainActor () -> Void = {},
        stopCue: @escaping @MainActor () -> Void = {}
    ) {
        self.time = time
        self.notifications = notifications
        self.isEnabled = isEnabled
        self.isForeground = isForeground
        self.playCue = playCue
        self.stopCue = stopCue
    }

    func prepare() {
        guard isEnabled(), let notifications else { return }
        Task {
            guard await notifications.restAlertAuthorization() == .notDetermined, isForeground() else { return }
            do {
                guard try await notifications.requestAuthorization(),
                      let deadline, deadline > time.now else { return }
                setDeadline(deadline)
            } catch {
                logger.error("Could not request rest notification permission: \(error.localizedDescription)")
            }
        }
    }

    func setDeadline(_ deadline: Date?) {
        if let notificationID { notifications?.removeRestAlert(id: notificationID) }
        notificationID = nil
        hasDeliveredCue = false
        stopCue()
        self.deadline = deadline
        guard let deadline, isEnabled(), let notifications else { return }

        let id = Self.requestPrefix + UUID().uuidString
        notificationID = id
        Task {
            let authorization = await notifications.restAlertAuthorization()
            guard notificationID == id else { return }
            guard authorization == .authorized, isEnabled(), deadline > time.now else {
                useForegroundFallback(id: id)
                return
            }
            do {
                guard try await notifications.scheduleRestAlert(id: id, deadline: deadline) else {
                    useForegroundFallback(id: id)
                    return
                }
                // An in-flight add can finish after skip, extension, or session teardown.
                if notificationID != id { notifications.removeRestAlert(id: id) }
            } catch {
                logger.error("Could not schedule rest notification: \(error.localizedDescription)")
                useForegroundFallback(id: id)
            }
        }
    }

    func enterForeground() {
        foregroundSince = time.now
    }

    func restDidFinish() {
        guard notificationID == nil else { return }
        playForegroundCue()
    }

    /// Returns true when the system should present the alert during a foreground transition.
    func shouldPresentNotification(id: String) -> Bool {
        guard notificationID == id, isEnabled(), !hasDeliveredCue else { return false }
        if isForeground() {
            playForegroundCue()
            return false
        }
        hasDeliveredCue = true
        return true
    }

    private func useForegroundFallback(id: String) {
        guard notificationID == id else { return }
        notificationID = nil
        playForegroundCue()
    }

    private func playForegroundCue() {
        guard let deadline, deadline >= foregroundSince, (0..<2).contains(time.now.timeIntervalSince(deadline)),
              isForeground(), isEnabled(), !hasDeliveredCue else { return }
        hasDeliveredCue = true
        playCue()
    }
}
