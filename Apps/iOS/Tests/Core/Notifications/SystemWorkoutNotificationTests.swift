import Foundation
import UserNotifications
import Testing
#if ONLYWEIGHTS
@testable import onlyweights
#else
@testable import onlybody
#endif

@MainActor
struct SystemWorkoutNotificationTests {
    @Test func requestUsesWeeklyLocalTimeAndSystemSoundWithoutBadge() throws {
        let planned = WorkoutReminderRequest(weekday: 7, time: WorkoutReminderTime(minutes: 795))
        let request = SystemWorkoutNotificationClient.notificationRequest(for: planned)
        let trigger = try #require(request.trigger as? UNCalendarNotificationTrigger)
        #expect(request.identifier == planned.identifier)
        #expect(request.content.title == "Training day")
        #expect(request.content.body == "You have a workout scheduled for today.")
        #expect(request.content.sound != nil)
        #expect(request.content.badge == nil)
        #expect(trigger.repeats)
        #expect(trigger.dateComponents.weekday == 7)
        #expect(trigger.dateComponents.hour == 13)
        #expect(trigger.dateComponents.minute == 15)
        #expect(trigger.dateComponents.timeZone == nil)
        #expect(trigger.dateComponents.year == nil)
        #expect(trigger.dateComponents.day == nil)
    }

    @Test func timeAlreadyPassedTodaySchedulesTheFollowingWeek() throws {
        let now = Date.now
        let weekday = Calendar.current.component(.weekday, from: now)
        let request = SystemWorkoutNotificationClient.notificationRequest(
            for: WorkoutReminderRequest(weekday: weekday, time: WorkoutReminderTime(minutes: 0))
        )
        let trigger = try #require(request.trigger as? UNCalendarNotificationTrigger)
        let next = try #require(trigger.nextTriggerDate())
        #expect(next > now)
        #expect(next.timeIntervalSince(now) > 6 * 23 * 60 * 60)
        #expect(Calendar.current.component(.weekday, from: next) == weekday)
    }
}
