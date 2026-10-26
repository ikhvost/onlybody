import XCTest

/// Exercises the shipping UI and repositories against a private, seeded file store.
@MainActor
final class WorkoutJourneyTests: XCTestCase {
    private var app: XCUIApplication!

    override func setUp() async throws {
        await MainActor.run {
            continueAfterFailure = false
            app = XCUIApplication()
            app.launchArguments = ["-AppleLanguages", "(en)", "-AppleLocale", "en_US"]
            app.launchEnvironment["ONLYBODY_UI_FIXTURE"] = "catalog"
            app.launchEnvironment["ONLYBODY_UI_STORE"] = UUID().uuidString
            app.launchEnvironment["ONLYBODY_DEMONSTRATION_FIXTURE"] = "ready"
            app.launchEnvironment["ONLYBODY_NOTIFICATION_FIXTURE"] = "authorized"
            app.launch()
        }
    }

    override func tearDown() async throws {
        await MainActor.run {
            if let testRun, testRun.hasSucceeded == false {
                let screenshot = XCTAttachment(screenshot: app.screenshot())
                screenshot.lifetime = .keepAlways
                add(screenshot)
            }
            app.terminate()
        }
    }

    func testCreateSurvivesRelaunch() {
        XCTAssertTrue(app.staticTexts[JourneyProduct.name].waitForExistence(timeout: 10))
        createWorkout(duration: "35 min", rest: "90 sec")
        app.terminate()
        app.launch()
        tap("workout.edit.E2E Workout")
        XCTAssertEqual(app.textFields["builder.name"].value as? String, "E2E Workout")
        XCTAssertTrue(app.buttons["builder.duration"].label.contains("35 minutes"))
        XCTAssertTrue(app.buttons["builder.rest"].label.contains("90 seconds"))
        tap("builder.duration")
        app.pickerWheels.firstMatch.adjust(toPickerWheelValue: "45 min")
        tap("timing.done")
        tap("builder.rest")
        app.pickerWheels.firstMatch.adjust(toPickerWheelValue: "60 sec")
        tap("timing.done")
        tap("builder.save")
        app.terminate()
        app.launch()
        tap("workout.edit.E2E Workout")
        XCTAssertTrue(app.buttons["builder.duration"].label.contains("45 minutes"))
        XCTAssertTrue(app.buttons["builder.rest"].label.contains("60 seconds"))
    }

    func testEditSurvivesRelaunch() {
        createWorkout()
        tap("workout.edit.E2E Workout")
        tap("stepper.Reps.increase")
        tap("builder.save")
        app.terminate()
        app.launch()
        tap("workout.edit.E2E Workout")
        XCTAssertTrue(app.staticTexts["1 SETS · 13 REPS · 45S REST"].exists)
        tap("builder.add")
        selectExercise()
        tap("builder.save")
        tap("workout.edit.E2E Workout")
        XCTAssertEqual(app.staticTexts.matching(identifier: "stepper.Sets.value").count, 2)
    }

    func testCompleteWritesOneSession() {
        tap("train.settings")
        selectWeightUnit("Pounds (lb)")
        tap("settings.back")
        createWorkout(sets: 2)
        tap("workout.start.E2E Workout")
        tap("stepper.Added lb.increase")
        XCTAssertEqual(app.staticTexts["stepper.Added lb.value"].label, "5")
        tap("active.markSetDone")
        tap("rest.skip")
        tap("stepper.Added lb.increase")
        XCTAssertEqual(app.staticTexts["stepper.Added lb.value"].label, "10")
        tap("active.markSetDone")
        tap("active.close")
        tap("workout.start.E2E Workout")
        tap("active.history")
        XCTAssertEqual(app.staticTexts["exerciseHistory.name"].label, JourneyProduct.exercise)
        XCTAssertFalse(app.staticTexts["exerciseHistory.totalReps"].exists)
        XCTAssertFalse(app.staticTexts["exerciseHistory.totals"].exists)
        XCTAssertTrue(app.staticTexts["exerciseHistory.date"].waitForExistence(timeout: 10))
        XCTAssertFalse(app.staticTexts["History"].exists)
        let firstSet = app.staticTexts["exerciseHistory.set.0"]
        let secondSet = app.staticTexts["exerciseHistory.set.1"]
        XCTAssertTrue(firstSet.label.contains("12 reps"))
        XCTAssertTrue(firstSet.label.contains("5 lb"))
        XCTAssertTrue(secondSet.label.contains("12 reps"))
        XCTAssertTrue(secondSet.label.contains("10 lb"))
        tap("exerciseHistory.back")
        tap("active.end")
        tap("Continue")
        app.terminate()
        app.launch()
        verifyConvertedWeightHistory()
        verifyHistory(reps: 24, firstSetReps: 12)
        swipeBack()
        XCTAssertTrue(app.buttons["session.row"].waitForExistence(timeout: 10))
        app.terminate()
        app.launch()
        tap("tab.log")
        XCTAssertTrue(app.buttons["session.row"].waitForExistence(timeout: 10))
        XCTAssertEqual(app.buttons.matching(identifier: "session.row").count, 1)
        tap("tab.train")
        tap("workout.edit.E2E Workout")
        let delete = app.buttons["builder.delete"]
        for _ in 0..<6 where !delete.isHittable { app.swipeUp() }
        XCTAssertTrue(delete.isHittable)
        delete.tap()
        tap("Cancel")
        XCTAssertTrue(app.buttons["builder.save"].exists)
        delete.tap()
        app.alerts.buttons["Delete Workout"].tap()
        XCTAssertTrue(app.buttons["workout.create"].waitForExistence(timeout: 10))
        XCTAssertFalse(app.buttons["workout.start.E2E Workout"].exists)
        app.terminate()
        app.launch()
        XCTAssertFalse(app.buttons["workout.start.E2E Workout"].exists)
        verifyHistory(reps: 24, firstSetReps: 12)
    }

    func testEarlyFinishPreservesCompletedSets() {
        createWorkout(sets: 2)
        tap("workout.start.E2E Workout")
        tap("active.markSetDone")
        tap("rest.skip")
        tap("active.end")
        tap("Continue")
        XCTAssertTrue(app.buttons["active.markSetDone"].exists)
        tap("active.end")
        tap("End Without Saving")
        tap("tab.log")
        XCTAssertEqual(app.buttons.matching(identifier: "session.row").count, 0)
        app.terminate()
        app.launch()
        tap("tab.log")
        XCTAssertEqual(app.buttons.matching(identifier: "session.row").count, 0)
        tap("tab.train")
        tap("workout.start.E2E Workout")
        tap("active.markSetDone")
        tap("rest.skip")
        tap("active.end")
        tap("End & Save")
        verifyHistory(reps: 12)
        XCTAssertFalse(app.staticTexts["SET 2 · 12 REPS"].exists)
    }

    func testNavigationAndFullscreenWorkout() {
        app.terminate()
        app.launchEnvironment["ONLYBODY_DEMONSTRATION_FIXTURE"] = "web"
        app.launch()
        verifySettingsNavigation()
        createWorkout()
        verifyOtherBackScreens()
        verifyTabSwipesAndDraftProtection()
        tap("tab.library")
        tap("difficulty.intermediate")
        XCTAssertTrue(app.descendants(matching: .any)["library.section.intermediate"].exists)
        XCTAssertFalse(app.descendants(matching: .any)["library.section.beginner"].exists)
        tap("difficulty.beginner")
        let search = app.textFields["library.search"]
        search.tap()
        search.typeText(JourneyProduct.libraryExercise)
        let movement = app.buttons["library.exercise.\(JourneyProduct.libraryExercise)"]
        XCTAssertTrue(movement.waitForExistence(timeout: 10))
        movement.tap()
        XCTAssertTrue(app.staticTexts["movement.difficulty"].label.contains("Beginner"))
        XCTAssertFalse(app.buttons["Set frequency to More often"].exists)
        XCTAssertFalse(app.buttons["Set frequency to Less often"].exists)
        XCTAssertFalse(app.buttons["Set frequency to Exclude"].exists)
        let diagram = app.descendants(matching: .any)["movement.muscleDiagram"]
        XCTAssertTrue(diagram.exists)
        XCTAssertTrue(diagram.label.contains("Muscle groups, front and back views"))
        let screenshot = XCTAttachment(screenshot: app.screenshot())
        screenshot.name = "\(JourneyProduct.name) movement details"
        screenshot.lifetime = .keepAlways
        add(screenshot)
        if JourneyProduct.hasDemonstrations {
            XCTAssertTrue(app.descendants(matching: .any)["demonstration.player"].waitForExistence(timeout: 10))
            XCTAssertFalse(app.buttons["demonstration.load"].exists)
            XCTAssertTrue(app.staticTexts["demonstration.author"].exists)
            XCTAssertFalse(app.buttons["demonstration.openYouTube"].exists)
            XCTAssertGreaterThan(app.webViews.count, 0, "The player uses local HTML and must not contact YouTube")
            let play = app.buttons["Play demonstration"].firstMatch
            XCTAssertTrue(play.waitForExistence(timeout: 10))
            play.tap()
            XCTAssertTrue(app.buttons["Pause demonstration"].firstMatch.exists)
            app.swipeRight()
            XCTAssertTrue(app.buttons["movement.back"].exists)
            cancelBackSwipe()
            XCTAssertTrue(app.buttons["movement.back"].exists)
            swipeBackOverPlayer()
        } else {
            XCTAssertTrue(app.staticTexts["demonstration.unavailable"].exists)
            XCTAssertEqual(app.webViews.count, 0)
            cancelBackSwipe()
            XCTAssertTrue(app.buttons["movement.back"].exists)
            swipeBack()
        }
        XCTAssertTrue(app.textFields["library.search"].waitForExistence(timeout: 10))
        tap("tab.log")
        tap("tab.train")
        tap("workout.edit.E2E Workout")
        XCTAssertFalse(app.buttons["tab.train"].isHittable)
        tap("builder.save")
        tap("workout.start.E2E Workout")
        XCTAssertTrue(app.buttons["active.markSetDone"].waitForExistence(timeout: 10))
        XCTAssertFalse(app.buttons["tab.train"].isHittable)
        verifyExerciseScreensReturnToWorkout()
        tap("active.end")
        tap("Continue")
        XCTAssertTrue(app.buttons["active.markSetDone"].exists)
        tap("active.end")
        tap("End & Save")
        XCTAssertTrue(app.buttons["tab.train"].waitForExistence(timeout: 10))
    }

    private func verifySettingsNavigation() {
        XCTAssertTrue(app.buttons["train.settings"].waitForExistence(timeout: 10))
        let header = XCTAttachment(screenshot: app.screenshot())
        header.name = "\(JourneyProduct.name) train settings entry"
        header.lifetime = .keepAlways
        add(header)
        tap("train.settings")
        XCTAssertTrue(app.buttons["settings.back"].waitForExistence(timeout: 10))
        XCTAssertFalse(app.buttons["tab.train"].isHittable)
        verifyTimerSoundPreference()
        verifyNotificationPreferences()
        verifyWeightUnitPreference()
        XCTAssertFalse(app.buttons["settings.rate"].exists)
        XCTAssertTrue(app.buttons["settings.feedback"].isEnabled)
        XCTAssertTrue(app.buttons["settings.privacy"].isEnabled)
        XCTAssertTrue(app.buttons["settings.terms"].isEnabled)
        XCTAssertTrue(app.staticTexts["settings.version"].label.contains(JourneyProduct.name))
        XCTAssertFalse(app.staticTexts["settings.version"].label.contains("—"))
        let settings = XCTAttachment(screenshot: app.screenshot())
        settings.name = "\(JourneyProduct.name) settings"
        settings.lifetime = .keepAlways
        add(settings)
        tap("settings.back")
        XCTAssertTrue(app.buttons["tab.train"].waitForExistence(timeout: 10))
        tap("train.settings")
        swipeBack()
        XCTAssertTrue(app.buttons["workout.create"].waitForExistence(timeout: 10))
    }

    private func verifyTimerSoundPreference() {
        let timerSound = app.switches["settings.timerSound"]
        XCTAssertTrue(timerSound.waitForExistence(timeout: 10))
        XCTAssertEqual(timerSound.value as? String, "1")
        timerSound.tap()
        XCTAssertEqual(timerSound.value as? String, "0")
        app.terminate()
        app.launch()
        tap("train.settings")
        XCTAssertTrue(timerSound.waitForExistence(timeout: 10))
        XCTAssertEqual(timerSound.value as? String, "0")
        timerSound.tap()
        XCTAssertEqual(timerSound.value as? String, "1")
    }

    private func selectWeightUnit(_ title: String) {
        tap("settings.weightUnit")
        tap(title)
        XCTAssertEqual(app.buttons["settings.weightUnit"].value as? String, title)
    }

    private func verifyWeightUnitPreference() {
        XCTAssertEqual(app.buttons["settings.weightUnit"].value as? String, "Kilograms (kg)")
        selectWeightUnit("Pounds (lb)")
        app.terminate()
        app.launch()
        tap("train.settings")
        XCTAssertEqual(app.buttons["settings.weightUnit"].value as? String, "Pounds (lb)")
        selectWeightUnit("Kilograms (kg)")
    }

    private func verifyConvertedWeightHistory() {
        tap("train.settings")
        XCTAssertEqual(app.buttons["settings.weightUnit"].value as? String, "Pounds (lb)")
        selectWeightUnit("Kilograms (kg)")
        tap("settings.back")
        tap("workout.start.E2E Workout")
        tap("active.history")
        XCTAssertTrue(app.staticTexts["exerciseHistory.date"].waitForExistence(timeout: 10))
        XCTAssertTrue(app.staticTexts["exerciseHistory.set.0"].label.contains("2.27 kg"))
        XCTAssertTrue(app.staticTexts["exerciseHistory.set.1"].label.contains("4.54 kg"))
        tap("exerciseHistory.back")
        tap("stepper.Added kg.increase")
        XCTAssertEqual(app.staticTexts["stepper.Added kg.value"].label, "2.5")
        tap("active.end")
        tap("End Without Saving")
    }

    private func verifyNotificationPreferences() {
        tap("settings.notifications")
        XCTAssertFalse(app.buttons["tab.train"].isHittable)
        let reminders = app.switches["notifications.enabled"]
        XCTAssertTrue(reminders.waitForExistence(timeout: 10))
        XCTAssertEqual(reminders.value as? String, "0")
        XCTAssertFalse(app.pickerWheels.firstMatch.exists)
        reminders.tap()
        let time = app.pickerWheels.firstMatch
        XCTAssertTrue(time.waitForExistence(timeout: 10))
        XCTAssertEqual(time.value as? String, "13:00")
        XCTAssertTrue(app.staticTexts["notifications.noDays"].exists)
        time.adjust(toPickerWheelValue: "13:30")
        let screenshot = XCTAttachment(screenshot: app.screenshot())
        screenshot.name = "\(JourneyProduct.name) notifications"
        screenshot.lifetime = .keepAlways
        add(screenshot)
        app.terminate()
        app.launch()
        tap("train.settings")
        tap("settings.notifications")
        XCTAssertTrue(time.waitForExistence(timeout: 10))
        XCTAssertEqual(reminders.value as? String, "1")
        XCTAssertEqual(time.value as? String, "13:30")
        reminders.tap()
        XCTAssertFalse(time.exists)
        reminders.tap()
        XCTAssertTrue(time.waitForExistence(timeout: 10))
        XCTAssertEqual(time.value as? String, "13:30")
        tap("notifications.back")
        tap("settings.notifications")
        swipeBack()
        XCTAssertTrue(app.buttons["settings.back"].waitForExistence(timeout: 10))
    }

    private func verifyOtherBackScreens() {
        tap("workout.create")
        XCTAssertTrue(app.buttons["picker.manual"].waitForExistence(timeout: 10))
        swipeBack()
        XCTAssertTrue(app.buttons["workout.start.E2E Workout"].waitForExistence(timeout: 10))
        XCTAssertFalse(app.buttons["OnlyBody — show streak"].exists)
        tap("tab.log")
        XCTAssertTrue(app.descendants(matching: .any)["log.activity"].waitForExistence(timeout: 10))
        tap("tab.train")
    }

    private func swipeBackOverPlayer() {
        let player = app.webViews.firstMatch
        let start = app.coordinate(withNormalizedOffset: .zero)
            .withOffset(CGVector(dx: 56, dy: player.frame.midY))
        let end = app.coordinate(withNormalizedOffset: .zero)
            .withOffset(CGVector(dx: app.frame.width * 0.85, dy: player.frame.midY))
        start.press(forDuration: 0.05, thenDragTo: end)
    }

    private func cancelBackSwipe() {
        let start = app.coordinate(withNormalizedOffset: CGVector(dx: 0, dy: 0.5))
            .withOffset(CGVector(dx: 56, dy: 0))
        let end = app.coordinate(withNormalizedOffset: CGVector(dx: 0.18, dy: 0.5))
        start.press(forDuration: 0.05, thenDragTo: end, withVelocity: .slow, thenHoldForDuration: 0.5)
    }

    private func swipeBack() {
        let start = app.coordinate(withNormalizedOffset: CGVector(dx: 0, dy: 0.5))
            .withOffset(CGVector(dx: 56, dy: 0))
        let end = app.coordinate(withNormalizedOffset: CGVector(dx: 0.85, dy: 0.5))
        start.press(forDuration: 0.05, thenDragTo: end)
    }

    private func verifyTabSwipesAndDraftProtection() {
        let start = app.coordinate(withNormalizedOffset: CGVector(dx: 0.7, dy: 0.7))
        let end = start.withOffset(CGVector(dx: -35, dy: 0))
        start.press(forDuration: 0.05, thenDragTo: end, withVelocity: .slow, thenHoldForDuration: 0.5)
        XCTAssertTrue(app.buttons["workout.start.E2E Workout"].exists)
        app.swipeLeft()
        XCTAssertTrue(app.staticTexts["NO TRAINING HISTORY YET"].waitForExistence(timeout: 10))
        app.swipeLeft()
        XCTAssertTrue(app.textFields["library.search"].waitForExistence(timeout: 10))
        app.swipeRight()
        XCTAssertTrue(app.staticTexts["NO TRAINING HISTORY YET"].waitForExistence(timeout: 10))
        app.swipeRight()
        tap("workout.edit.E2E Workout")
        tap("stepper.Reps.increase")
        swipeBack()
        tap("Stay")
        XCTAssertTrue(app.textFields["builder.name"].exists)
        tap("builder.back")
        tap("Discard changes")
        tap("workout.edit.E2E Workout")
        XCTAssertTrue(app.staticTexts["1 SETS · 12 REPS · 45S REST"].exists)
        swipeBack()
        XCTAssertTrue(app.buttons["workout.start.E2E Workout"].waitForExistence(timeout: 10))
    }

    private func verifyExerciseScreensReturnToWorkout() {
        tap("stepper.Reps.increase")
        tap("stepper.Added kg.increase")
        tap("active.guide")
        XCTAssertTrue(app.staticTexts[JourneyProduct.exercise].exists)
        XCTAssertFalse(app.staticTexts["Movement"].exists)
        XCTAssertEqual(app.buttons["movement.back"].label, "Back to workout")
        if JourneyProduct.hasDemonstrations {
            XCTAssertTrue(app.descendants(matching: .any)["demonstration.player"].waitForExistence(timeout: 10))
            XCTAssertGreaterThan(app.webViews.count, 0)
            swipeBackOverPlayer()
        } else {
            XCTAssertTrue(app.staticTexts["demonstration.unavailable"].waitForExistence(timeout: 10))
            XCTAssertEqual(app.webViews.count, 0)
            swipeBack()
        }
        tap("active.history")
        XCTAssertTrue(app.staticTexts["exerciseHistory.empty"].waitForExistence(timeout: 10))
        swipeBack()
        XCTAssertEqual(app.staticTexts["stepper.Reps.value"].label, "13")
        XCTAssertEqual(app.staticTexts["stepper.Added kg.value"].label, "2.5")
        XCTAssertTrue(app.buttons["active.markSetDone"].exists)
        XCTAssertFalse(app.buttons["tab.train"].isHittable)
    }

    private func createWorkout(sets: Int = 1, duration: String? = nil, rest: String? = nil) {
        tap("workout.create")
        tap("picker.manual")
        let name = app.textFields["builder.name"]
        XCTAssertTrue(name.waitForExistence(timeout: 10))
        name.tap()
        name.typeText("E2E Workout\n")
        if let duration {
            tap("builder.duration")
            app.pickerWheels.firstMatch.adjust(toPickerWheelValue: duration)
            tap("timing.done")
        }
        if let rest {
            tap("builder.rest")
            app.pickerWheels.firstMatch.adjust(toPickerWheelValue: rest)
            tap("timing.done")
        }
        tap("builder.add")
        selectExercise()
        for _ in sets..<3 { tap("stepper.Sets.decrease") }
        tap("builder.save")
        XCTAssertTrue(app.buttons["workout.start.E2E Workout"].waitForExistence(timeout: 10))
    }

    private func selectExercise() {
        let search = app.textFields["Search movements..."]
        XCTAssertTrue(search.waitForExistence(timeout: 10))
        search.tap()
        search.typeText(JourneyProduct.exercise)
        let exercise = app.buttons["exercise.pick.\(JourneyProduct.exercise)"]
        // Fixture uses the catalog's exact display name.
        XCTAssertTrue(exercise.waitForExistence(timeout: 10))
        exercise.tap()
    }

    private func verifyHistory(reps: Int, firstSetReps: Int? = nil) {
        tap("tab.log")
        let row = app.buttons["session.row"]
        XCTAssertTrue(row.waitForExistence(timeout: 10))
        XCTAssertEqual(app.buttons.matching(identifier: "session.row").count, 1)
        row.tap()
        let total = app.staticTexts["session.total.0"]
        XCTAssertTrue(total.waitForExistence(timeout: 10), app.debugDescription)
        XCTAssertEqual(total.label, "\(reps) REPS TOTAL")
        XCTAssertEqual(app.staticTexts["session.set.0.0"].label, "SET 1 · \(firstSetReps ?? reps) REPS")
    }

    private func tap(_ identifier: String) {
        let button = app.buttons[identifier]
        XCTAssertTrue(button.waitForExistence(timeout: 10), "Missing button: \(identifier)")
        button.tap()
    }
}
