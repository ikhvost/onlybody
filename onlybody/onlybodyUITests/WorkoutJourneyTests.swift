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
        XCTAssertTrue(app.buttons["train.settings"].waitForExistence(timeout: 10))
        createWorkout(duration: "35 min", rest: "90 sec")
        app.terminate()
        app.launch()
        tap("workout.edit.E2E Workout")
        XCTAssertEqual(app.textFields["builder.name"].value as? String, "E2E Workout")
        showTimingOptions()
        XCTAssertTrue(app.buttons["builder.duration"].label.contains("35 min"))
        XCTAssertTrue(app.buttons["builder.rest"].label.contains("90 sec"))
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
        showTimingOptions()
        XCTAssertTrue(app.buttons["builder.duration"].label.contains("45 min"))
        XCTAssertTrue(app.buttons["builder.rest"].label.contains("60 sec"))
    }

    func testEditSurvivesRelaunch() {
        createWorkout()
        tap("workout.edit.E2E Workout")
        tap("stepper.Reps.increase")
        let reps = app.textFields["stepper.Reps.value"]
        reps.coordinate(withNormalizedOffset: CGVector(dx: 0.95, dy: 0.5)).tap()
        reps.typeText(String(repeating: XCUIKeyboardKey.delete.rawValue, count: 2))
        XCTAssertFalse(app.buttons["builder.movement.done"].isEnabled)
        reps.typeText("130")
        dismissKeyboardOutside(reps)
        XCTAssertTrue(app.buttons["builder.movement.done"].isEnabled)
        tap("builder.save")
        app.terminate()
        app.launch()
        tap("workout.edit.E2E Workout")
        XCTAssertTrue(app.staticTexts["Sets: 1 · Reps: 130 · Rest: 45 sec"].exists)
        tap("builder.add")
        selectExercise()
        tap("builder.save")
        tap("workout.edit.E2E Workout")
        XCTAssertEqual(app.buttons.matching(NSPredicate(format: "identifier BEGINSWITH %@", "builder.movement.")).count, 2)
        verifyEditorReordering()
        tap("builder.save")
        tap("workout.start.E2E Workout")
        tap("active.exercise.0.replace")
        let replacementSearch = app.textFields["exercisePicker.search"]
        XCTAssertTrue(replacementSearch.waitForExistence(timeout: 10))
        replacementSearch.tap()
        replacementSearch.typeText(JourneyProduct.libraryExercise)
        tap("exercise.pick.\(JourneyProduct.libraryExercise)")
        verifySessionDragReordering()
        tap("active.exercise.0.down")
        XCTAssertTrue(app.buttons["active.exercise.1"].label.contains(JourneyProduct.libraryExercise))
        tap("active.exercise.1.up")
        XCTAssertTrue(app.buttons["active.exercise.0"].label.contains(JourneyProduct.libraryExercise))
        tap("active.exercise.0.down")
        XCTAssertTrue(app.buttons["active.exercise.1"].label.contains(JourneyProduct.libraryExercise))
        tap("active.start")
        tap("active.set.0.done")
        tap("active.list")
        XCTAssertFalse(app.buttons["active.exercise.0.replace"].isEnabled)
        tap("active.exercise.0")
        setValue("125", field: "reps", index: 0)
        tap("active.list")
        tap("active.end")
        tap("End Without Saving")
        tap("workout.edit.E2E Workout")
        XCTAssertTrue(app.staticTexts["Sets: 1 · Reps: 130 · Rest: 45 sec"].waitForExistence(timeout: 10))
        let savedRows = app.buttons.matching(NSPredicate(format: "identifier BEGINSWITH %@", "builder.movement."))
        XCTAssertFalse(savedRows.allElementsBoundByIndex.contains { $0.label.contains(JourneyProduct.libraryExercise) })
    }

    func testCompleteWritesOneSession() {
        tap("train.settings")
        selectWeightUnit("Pounds (lb)")
        tap("settings.back")
        createWorkout(sets: 2)
        tap("workout.start.E2E Workout")
        tap("active.start")
        replaceInitialZeroWithFive()
        tap("active.set.0.done")
        tap("rest.skip")
        XCTAssertFalse(app.keyboards.firstMatch.exists)
        setValue("10", field: "weight", index: 1)
        tap("active.set.1.done")
        // All checks return to the list; results are saved only after explicit finish.
        tap("active.end")
        tap("End & Save")
        tap("active.close")
        tap("workout.start.E2E Workout")
        tap("active.start")
        tap("active.history")
        XCTAssertEqual(app.staticTexts["exerciseHistory.name"].label, JourneyProduct.exercise)
        XCTAssertFalse(app.staticTexts["exerciseHistory.totalReps"].exists)
        XCTAssertFalse(app.staticTexts["exerciseHistory.totals"].exists)
        XCTAssertTrue(app.staticTexts["exerciseHistory.date"].waitForExistence(timeout: 10))
        XCTAssertFalse(app.staticTexts["History"].exists)
        let firstSet = app.staticTexts["exerciseHistory.set.0"]
        let secondSet = app.staticTexts["exerciseHistory.set.1"]
        XCTAssertTrue(firstSet.label.contains("Reps: 12"))
        XCTAssertTrue(firstSet.label.contains("5 lb"))
        XCTAssertTrue(secondSet.label.contains("Reps: 12"))
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
        tap("builder.delete")
        tap("Cancel")
        XCTAssertTrue(app.buttons["builder.save"].exists)
        tap("builder.delete")
        app.alerts.buttons["Delete Workout"].tap()
        XCTAssertTrue(app.buttons["workout.create"].waitForExistence(timeout: 10))
        XCTAssertFalse(app.buttons["workout.start.E2E Workout"].exists)
        app.terminate()
        app.launch()
        XCTAssertFalse(app.buttons["workout.start.E2E Workout"].exists)
        verifyHistory(reps: 24, firstSetReps: 12)
        verifyLibraryOutsideDismissal()
    }

    func testEarlyFinishPreservesCompletedSets() {
        createWorkout(sets: 2)
        tap("workout.start.E2E Workout")
        tap("active.start")
        tap("active.set.0.done")
        tap("rest.skip")
        tap("active.end")
        tap("Continue")
        tap("active.resume")
        XCTAssertTrue(app.buttons["active.set.0.done"].exists)
        tap("active.end")
        tap("End Without Saving")
        tap("workout.start.E2E Workout")
        tap("active.start")
        tap("active.end")
        tap("End & Save")
        XCTAssertTrue(app.staticTexts["completion.status"].waitForExistence(timeout: 10))
        tap("active.close")
        tap("tab.log")
        XCTAssertEqual(app.buttons.matching(identifier: "session.row").count, 0)
        app.terminate()
        app.launch()
        tap("tab.log")
        XCTAssertEqual(app.buttons.matching(identifier: "session.row").count, 0)
        tap("tab.train")
        tap("workout.start.E2E Workout")
        tap("active.start")
        tap("active.set.0.done")
        tap("rest.skip")
        tap("active.end")
        tap("End & Save")
        tap("active.close")
        verifyHistory(reps: 12)
        XCTAssertFalse(app.staticTexts["Set 2 · Reps: 12"].exists)
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
        tap("catalog.filters")
        tap("difficulty.intermediate")
        tap("filters.done")
        XCTAssertFalse(app.descendants(matching: .any)["library.section.intermediate"].exists)
        tap("catalog.filters")
        tap("difficulty.beginner")
        tap("filters.done")
        let search = app.textFields["library.search"]
        search.tap()
        search.typeText(JourneyProduct.libraryExercise)
        dismissKeyboardOutside(search)
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
            let player = app.descendants(matching: .any)["demonstration.player"]
            for _ in 0..<5 where !player.isHittable || player.frame.maxY > app.frame.maxY { app.swipeUp() }
            XCTAssertTrue(player.waitForExistence(timeout: 10))
            XCTAssertGreaterThanOrEqual(player.frame.width, 200)
            XCTAssertGreaterThanOrEqual(player.frame.height, 200)
            let viewport = XCTAttachment(string: "Native fixture viewport: \(player.frame)")
            viewport.name = "YouTube fixture viewport"
            viewport.lifetime = .keepAlways
            add(viewport)
            XCTAssertFalse(app.buttons["demonstration.load"].exists)
            XCTAssertTrue(app.staticTexts["demonstration.author"].exists)
            XCTAssertTrue(app.buttons["demonstration.openYouTube"].exists)
            XCTAssertGreaterThan(app.webViews.count, 0, "The player uses local HTML and must not contact YouTube")
            let play = app.buttons["Play demonstration"].firstMatch
            XCTAssertTrue(play.waitForExistence(timeout: 10))
            play.tap()
            XCTAssertTrue(app.buttons["Pause demonstration"].firstMatch.waitForExistence(timeout: 10))
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
        tap("active.start")
        XCTAssertTrue(app.buttons["active.set.0.done"].waitForExistence(timeout: 10))
        XCTAssertFalse(app.buttons["tab.train"].isHittable)
        verifyExerciseScreensReturnToWorkout()
        tap("active.end")
        tap("Continue")
        tap("active.resume")
        XCTAssertTrue(app.buttons["active.set.0.done"].exists)
        tap("active.end")
        tap("End & Save")
        tap("active.close")
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
        tap("active.start")
        tap("active.history")
        XCTAssertTrue(app.staticTexts["exerciseHistory.date"].waitForExistence(timeout: 10))
        XCTAssertTrue(app.staticTexts["exerciseHistory.set.0"].label.contains("2.27 kg"))
        XCTAssertTrue(app.staticTexts["exerciseHistory.set.1"].label.contains("4.54 kg"))
        tap("exerciseHistory.back")
        setValue("2.5", field: "weight", index: 0)
        XCTAssertEqual(app.textFields["active.set.0.weight"].value as? String, "2.5")
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
        XCTAssertTrue(app.buttons["creation.manual"].waitForExistence(timeout: 10))
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
        XCTAssertTrue(app.staticTexts["No training history yet"].waitForExistence(timeout: 10))
        app.swipeLeft()
        XCTAssertTrue(app.textFields["library.search"].waitForExistence(timeout: 10))
        app.swipeRight()
        XCTAssertTrue(app.staticTexts["No training history yet"].waitForExistence(timeout: 10))
        app.swipeRight()
        tap("workout.edit.E2E Workout")
        tap("stepper.Reps.increase")
        tap("builder.movement.done")
        swipeBack()
        tap("Stay")
        XCTAssertTrue(app.textFields["builder.name"].exists)
        tap("builder.back")
        tap("Discard changes")
        tap("workout.edit.E2E Workout")
        XCTAssertTrue(app.staticTexts["Sets: 1 · Reps: 12 · Rest: 45 sec"].exists)
        swipeBack()
        XCTAssertTrue(app.buttons["workout.start.E2E Workout"].waitForExistence(timeout: 10))
    }

    private func verifyExerciseScreensReturnToWorkout() {
        setValue("13", field: "reps", index: 0)
        setValue("2.5", field: "weight", index: 0)
        tap("active.guide")
        XCTAssertTrue(app.staticTexts[JourneyProduct.exercise].exists)
        XCTAssertFalse(app.staticTexts["Movement"].exists)
        XCTAssertEqual(app.buttons["movement.back"].label, "Back to workout")
        if JourneyProduct.hasDemonstrations {
            let player = app.descendants(matching: .any)["demonstration.player"]
            for _ in 0..<5 where !player.isHittable || player.frame.maxY > app.frame.maxY { app.swipeUp() }
            XCTAssertTrue(player.waitForExistence(timeout: 10))
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
        XCTAssertEqual(app.textFields["active.set.0.reps"].value as? String, "13")
        XCTAssertEqual(app.textFields["active.set.0.weight"].value as? String, "2.5")
        XCTAssertTrue(app.buttons["active.set.0.done"].exists)
        XCTAssertFalse(app.buttons["tab.train"].isHittable)
    }

    private func createWorkout(sets: Int = 1, duration: String? = nil, rest: String? = nil) {
        tap("workout.create")
        tap("creation.manual")
        selectExercise()
        let name = app.textFields["builder.name"]
        XCTAssertTrue(name.waitForExistence(timeout: 10))
        name.tap()
        name.typeText("E2E Workout")
        dismissKeyboardOutside(name)
        if duration != nil || rest != nil { showTimingOptions() }
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
        if duration != nil || rest != nil { tap("builder.options") }
        for _ in sets..<3 { tap("stepper.Sets.decrease") }
        tap("builder.save")
        XCTAssertTrue(app.buttons["workout.start.E2E Workout"].waitForExistence(timeout: 10))
        tap("workout.overview.E2E Workout")
        XCTAssertTrue(app.buttons["active.start"].waitForExistence(timeout: 10))
        XCTAssertTrue(app.buttons["active.exercise.0"].exists)
        tap("active.back")
    }

    private func showTimingOptions() {
        tap("builder.options")
        let duration = app.buttons["builder.duration"]
        for _ in 0..<6 where !duration.exists || !duration.isHittable { app.swipeUp() }
        XCTAssertTrue(duration.exists || duration.waitForExistence(timeout: 10), app.debugDescription)
    }

    private func selectExercise() {
        let search = app.textFields["exercisePicker.search"]
        XCTAssertTrue(search.waitForExistence(timeout: 10))
        search.tap()
        search.typeText(JourneyProduct.exercise)
        dismissKeyboardOutside(search)
        XCTAssertEqual(search.value as? String, JourneyProduct.exercise)
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
        XCTAssertEqual(total.label, "Total reps: \(reps)")
        XCTAssertEqual(app.staticTexts["session.set.0.0"].label, "Set 1 · Reps: \(firstSetReps ?? reps)")
    }

    private func verifyEditorReordering() {
        let rows = app.buttons.matching(NSPredicate(format: "identifier BEGINSWITH %@", "builder.movement."))
        let first = rows.element(boundBy: 0)
        let second = rows.element(boundBy: 1)
        let firstID = first.identifier
        let secondID = second.identifier
        let down = firstID.replacing("builder.movement.", with: "builder.order.") + ".down"
        let up = firstID.replacing("builder.movement.", with: "builder.order.") + ".up"
        tap(down)
        XCTAssertGreaterThan(app.buttons[firstID].frame.midY, app.buttons[secondID].frame.midY)
        tap(up)
        XCTAssertLessThan(app.buttons[firstID].frame.midY, app.buttons[secondID].frame.midY)
        let firstHandle = firstID.replacing("builder.movement.", with: "builder.drag.")
        let secondHandle = secondID.replacing("builder.movement.", with: "builder.drag.")
        dragExercise(firstHandle, to: secondHandle, extraDistance: 30)
        XCTAssertGreaterThan(app.buttons[firstID].frame.midY, app.buttons[secondID].frame.midY)
        dragExercise(firstHandle, to: secondHandle, extraDistance: -30)
        XCTAssertLessThan(app.buttons[firstID].frame.midY, app.buttons[secondID].frame.midY)
    }

    private func verifySessionDragReordering() {
        dragExercise("active.exercise.0.drag", to: "active.exercise.1.drag", extraDistance: 30)
        XCTAssertTrue(app.buttons["active.exercise.1"].label.contains(JourneyProduct.libraryExercise))
        dragExercise("active.exercise.1.drag", to: "active.exercise.0.drag", extraDistance: -30)
        XCTAssertTrue(app.buttons["active.exercise.0"].label.contains(JourneyProduct.libraryExercise))
    }

    private func dragExercise(_ sourceID: String, to targetID: String, extraDistance: CGFloat) {
        let source = app.descendants(matching: .any).matching(identifier: sourceID).firstMatch
        let target = app.descendants(matching: .any).matching(identifier: targetID).firstMatch
        XCTAssertTrue(source.waitForExistence(timeout: 5))
        XCTAssertTrue(target.waitForExistence(timeout: 5))
        let destination = target.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5))
            .withOffset(CGVector(dx: 0, dy: extraDistance))
        source.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5))
            .press(forDuration: 0.7, thenDragTo: destination, withVelocity: XCUIGestureVelocity(rawValue: 120), thenHoldForDuration: 1)
    }

    private func verifyLibraryOutsideDismissal() {
        swipeBack()
        tap("tab.library")
        let search = app.textFields["library.search"]
        XCTAssertTrue(search.waitForExistence(timeout: 10))
        search.tap()
        search.typeText(JourneyProduct.libraryExercise)
        dismissKeyboardOutside(search)
        XCTAssertEqual(search.value as? String, JourneyProduct.libraryExercise)
        XCTAssertTrue(app.buttons["library.exercise.\(JourneyProduct.libraryExercise)"].exists)
    }

    private func dismissKeyboardOutside(_ field: XCUIElement) {
        XCTAssertTrue(app.keyboards.firstMatch.waitForExistence(timeout: 5))
        let target: XCUIElement
        if field.identifier.hasPrefix("active.set.") {
            target = app.staticTexts["active.elapsed"]
        } else if field.identifier == "builder.name" {
            target = app.staticTexts["builder.name.label"]
        } else if field.identifier == "library.search" {
            target = app.staticTexts["library.title"]
        } else if field.identifier.hasPrefix("stepper.") {
            target = app.staticTexts["number.Reps.title"]
        } else {
            target = app.staticTexts["Add Exercise"].firstMatch
        }
        XCTAssertTrue(target.waitForExistence(timeout: 5))
        let outside = app.coordinate(withNormalizedOffset: .zero)
            .withOffset(CGVector(dx: app.frame.midX, dy: target.frame.midY))
        outside.tap()
        let hidden = XCTNSPredicateExpectation(predicate: NSPredicate(format: "exists == false"), object: app.keyboards.firstMatch)
        XCTAssertEqual(XCTWaiter.wait(for: [hidden], timeout: 5), .completed)
        XCTAssertFalse(app.buttons["keyboard.dismiss"].exists)
    }

    private func replaceInitialZeroWithFive() {
        if app.buttons["active.addWeight"].exists { tap("active.addWeight") }
        let weight = app.textFields["active.set.0.weight"]
        XCTAssertTrue(weight.waitForExistence(timeout: 10))
        weight.tap()
        dismissKeyboardOutside(weight)
        XCTAssertEqual(weight.value as? String, "0")
        weight.tap()
        weight.tap() // A second tap inside the field must keep editing active.
        XCTAssertTrue(app.keyboards.firstMatch.exists)
        weight.typeText("5")
        XCTAssertEqual(weight.value as? String, "5")
        dismissKeyboardOutside(weight)
        XCTAssertEqual(weight.value as? String, "5")
    }

    private func setValue(_ value: String, field: String, index: Int) {
        if field == "weight", app.buttons["active.addWeight"].exists { tap("active.addWeight") }
        let input = app.textFields["active.set.\(index).\(field)"]
        XCTAssertTrue(input.waitForExistence(timeout: 10))
        input.coordinate(withNormalizedOffset: CGVector(dx: 0.95, dy: 0.5)).tap()
        let text = input.value as? String ?? ""
        input.typeText(String(repeating: XCUIKeyboardKey.delete.rawValue, count: text.count) + value)
    }

    private func prepareEditor(for identifier: String) {
        if identifier.hasPrefix("stepper."), !app.buttons[identifier].exists, app.textFields["builder.name"].exists {
            let movement = app.buttons.matching(NSPredicate(format: "identifier BEGINSWITH %@", "builder.movement.")).firstMatch
            XCTAssertTrue(movement.waitForExistence(timeout: 10))
            for _ in 0..<5 where !movement.isHittable { app.swipeUp() }
            movement.tap()
        }
        if ["builder.save", "builder.add"].contains(identifier), app.buttons["builder.movement.done"].exists {
            tap("builder.movement.done")
        }
    }

    private func tap(_ identifier: String) {
        if identifier == "active.end", !app.buttons[identifier].exists { tap("active.list") }
        let alertButton = app.alerts.buttons[identifier]
        if alertButton.exists { alertButton.tap(); return }
        prepareEditor(for: identifier)
        let button = app.buttons[identifier].firstMatch
        if ["builder.duration", "builder.rest"].contains(identifier) {
            for _ in 0..<6 where !button.exists || !button.isHittable { app.swipeUp() }
        }
        XCTAssertTrue(button.exists || button.waitForExistence(timeout: 10), "Missing button: \(identifier)\n\(app.debugDescription)")
        for _ in 0..<6 {
            let save = app.buttons["builder.save"]
            let belowEditorFooter = identifier.hasPrefix("builder.") && identifier != "builder.save"
                && !identifier.hasPrefix("builder.movement.") && save.exists && button.frame.maxY > save.frame.minY
            if button.isHittable && !belowEditorFooter { break }
            app.swipeUp()
        }
        XCTAssertTrue(button.isHittable, "Not reachable: \(identifier)\n\(app.debugDescription)")
        button.tap()
        if identifier == "builder.movement.done" {
            let dismissed = NSPredicate(format: "exists == false")
            if XCTWaiter.wait(for: [XCTNSPredicateExpectation(predicate: dismissed, object: button)], timeout: 3) != .completed {
                button.tap()
                XCTAssertEqual(XCTWaiter.wait(for: [XCTNSPredicateExpectation(predicate: dismissed, object: button)], timeout: 3), .completed,
                               "Numeric sheet must close before interacting with its parent")
            }
        }
    }
}
