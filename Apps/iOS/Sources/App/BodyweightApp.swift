import SwiftData
import SwiftUI

@main
struct BodyweightApp: App {
    @Environment(\.scenePhase) private var scenePhase
    let configuration = AppConfiguration.current
    let container: ModelContainer?
    let exercises: any ExerciseRepository
    let workouts: any WorkoutRepository
    let sessions: any SessionRepository
    let preferences: WorkoutPreferences
    let reminders: WorkoutReminderCoordinator
    let systemNotifications: SystemWorkoutNotificationClient?
    let restAlerts: WorkoutRestAlerts?
    let liveActivity: SystemWorkoutLiveActivity?

    init() {
        #if DEBUG
        if ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1" || NativeDesignReviewRootView.isEnabled {
            container = nil
            exercises = PreviewExerciseRepository()
            workouts = PreviewWorkoutRepository()
            sessions = PreviewSessionRepository()
            preferences = WorkoutPreferences()
            systemNotifications = nil
            restAlerts = nil
            liveActivity = nil
            reminders = WorkoutReminderCoordinator(
                preferences: preferences, workouts: workouts, notifications: PreviewWorkoutNotificationClient()
            )
            return
        }
        #endif

        #if DEBUG
        let preferenceNamespace = ProcessInfo.processInfo.environment["ONLYBODY_UI_STORE"]
            .flatMap(UUID.init(uuidString:))?.uuidString
        #else
        let preferenceNamespace: String? = nil
        #endif
        preferences = WorkoutPreferencesStore(namespace: preferenceNamespace).makePreferences()

        do {
            let storeURL = try AppStoreLocation.url()
            guard let seedURL = Bundle.main.url(forResource: "default", withExtension: "store") else {
                throw PersistenceError.exerciseUnavailable
            }
            let catalog = try BundledExerciseCatalog.load(from: seedURL)

            if !FileManager.default.fileExists(atPath: storeURL.path()) {
                try FileManager.default.copyItem(at: seedURL, to: storeURL)
            }

            let config = ModelConfiguration(url: storeURL)
            let storeContainer = try ModelContainer(
                for: Exercise.self, Workout.self, WorkoutItem.self, Session.self, SessionItem.self,
                configurations: config
            )
            #if DEBUG
            try ScreenshotStoreFixture.populateIfRequested(storeContainer, product: configuration.displayName)
            #endif
            container = storeContainer
            exercises = SwiftDataExerciseRepository(context: ModelContext(storeContainer), catalog: catalog)
            workouts = SwiftDataWorkoutRepository(context: ModelContext(storeContainer), catalog: catalog)
            sessions = SwiftDataSessionRepository(context: ModelContext(storeContainer))
            let system = SystemWorkoutNotificationClient()
            #if DEBUG
            let isolatedUITest = preferenceNamespace != nil
            let useReminderFixture = isolatedUITest && ProcessInfo.processInfo.environment["ONLYBODY_NOTIFICATION_FIXTURE"] == "authorized"
            let notificationClient: any WorkoutNotificationClient = useReminderFixture ? PreviewWorkoutNotificationClient() : system
            #else
            let isolatedUITest = false
            let notificationClient: any WorkoutNotificationClient = system
            #endif
            systemNotifications = isolatedUITest ? nil : system
            reminders = WorkoutReminderCoordinator(preferences: preferences, workouts: workouts, notifications: notificationClient)
            let cue = WorkoutCuePlayer()
            let preferences = preferences
            let alerts = WorkoutRestAlerts(
                notifications: systemNotifications,
                isEnabled: { preferences.isTimerSoundEnabled },
                isForeground: { UIApplication.shared.applicationState == .active },
                playCue: { cue.play() }, stopCue: { cue.stop() }
            )
            restAlerts = alerts
            system.restAlerts = alerts
            liveActivity = isolatedUITest ? nil : SystemWorkoutLiveActivity()
            if let systemNotifications {
                Task { await systemNotifications.removeAbandonedRestAlerts() }
            }
        } catch {
            fatalError("ModelContainer failed: \(error)")
        }
    }

    var body: some Scene {
        WindowGroup {
            AppContentView(composition: AppComposition(
                configuration: configuration, exercises: exercises, workouts: workouts,
                sessions: sessions, preferences: preferences, reminders: reminders,
                restAlerts: restAlerts, restNotifications: systemNotifications, liveActivity: liveActivity
            ))
            .task { await reminders.refresh() }
            .onChange(of: scenePhase) { _, phase in
                if phase == .active { Task { await reminders.refresh() } }
            }
            .onReceive(NotificationCenter.default.publisher(for: .NSSystemTimeZoneDidChange)) { _ in
                Task { await reminders.refresh() }
            }
            .onReceive(NotificationCenter.default.publisher(for: UIApplication.significantTimeChangeNotification)) { _ in
                Task { await reminders.refresh() }
            }
            .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
                restAlerts?.enterForeground()
            }
        }
    }
}
