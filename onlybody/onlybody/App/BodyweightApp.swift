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
    let youtubeConsent: YouTubeConsent
    let preferences: WorkoutPreferences
    let reminders: WorkoutReminderCoordinator

    init() {
        #if DEBUG
        if ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1" {
            container = nil
            exercises = PreviewExerciseRepository()
            workouts = PreviewWorkoutRepository()
            sessions = PreviewSessionRepository()
            youtubeConsent = YouTubeConsent()
            preferences = WorkoutPreferences()
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
        youtubeConsent = YouTubeConsentStore(namespace: preferenceNamespace).makeConsent()
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
            container = storeContainer
            exercises = SwiftDataExerciseRepository(context: ModelContext(storeContainer), catalog: catalog)
            workouts = SwiftDataWorkoutRepository(context: ModelContext(storeContainer), catalog: catalog)
            sessions = SwiftDataSessionRepository(context: ModelContext(storeContainer))
            let notificationClient: any WorkoutNotificationClient
            #if DEBUG
            if preferenceNamespace != nil && ProcessInfo.processInfo.environment["ONLYBODY_NOTIFICATION_FIXTURE"] == "authorized" {
                notificationClient = PreviewWorkoutNotificationClient()
            } else {
                notificationClient = SystemWorkoutNotificationClient()
            }
            #else
            notificationClient = SystemWorkoutNotificationClient()
            #endif
            reminders = WorkoutReminderCoordinator(preferences: preferences, workouts: workouts, notifications: notificationClient)
        } catch {
            fatalError("ModelContainer failed: \(error)")
        }
    }

    var body: some Scene {
        WindowGroup {
            AppTabView(composition: AppComposition(
                configuration: configuration, exercises: exercises, workouts: workouts,
                sessions: sessions, preferences: preferences, reminders: reminders, youtubeConsent: youtubeConsent
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
        }
    }
}
