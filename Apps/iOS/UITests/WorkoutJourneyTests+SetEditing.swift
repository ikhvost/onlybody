import XCTest

@MainActor
extension WorkoutJourneyTests {
    func testActiveSetEditingPreservesHistoryAndTemplate() {
        createWorkout(sets: 2)
        tap("workout.start.E2E Workout")
        tap("active.start")
        showSetActions()
        let add = app.buttons["active.set.add"]
        let remove = app.buttons["active.set.removeLast"]
        XCTAssertTrue(add.isEnabled && remove.isEnabled)
        XCTAssertLessThan(remove.frame.midX, add.frame.midX)
        for button in [add, remove] {
            XCTAssertGreaterThanOrEqual(button.frame.width, 44)
            XCTAssertGreaterThanOrEqual(button.frame.height, 44)
        }
        setValue("8", field: "reps", index: 1)
        setValue("10", field: "weight", index: 1)
        dismissKeyboardOutside(app.textFields["active.set.1.weight"])
        tap("active.set.1.done")
        showSetActions()
        XCTAssertFalse(remove.isEnabled)
        tap("active.set.add")
        XCTAssertEqual(app.textFields["active.set.2.reps"].value as? String, "8")
        XCTAssertEqual(app.textFields["active.set.2.weight"].value as? String, "10")
        XCTAssertTrue(remove.isEnabled)
        tap("active.set.removeLast")
        XCTAssertFalse(app.textFields["active.set.2.reps"].exists)
        XCTAssertFalse(remove.isEnabled)
        tap("active.set.1.done")
        showSetActions()
        tap("active.set.removeLast")
        XCTAssertFalse(app.textFields["active.set.1.reps"].exists)
        XCTAssertFalse(remove.isEnabled)
        setValue("7", field: "reps", index: 0)
        dismissKeyboardOutside(app.textFields["active.set.0.reps"])
        showSetActions()
        tap("active.set.add")
        XCTAssertEqual(app.textFields["active.set.1.reps"].value as? String, "7")
        tap("active.set.0.done")
        tap("rest.skip")
        tap("active.set.1.done")
        tap("active.exercise.0")
        showSetActions()
        XCTAssertFalse(remove.isEnabled)
        tap("active.set.add")
        XCTAssertEqual(app.textFields["active.set.2.reps"].value as? String, "7")
        tap("active.set.2.done")
        tap("active.end")
        tap("End & Save")
        tap("active.close")
        verifyHistory(reps: 21, firstSetReps: 7)
        XCTAssertEqual(app.staticTexts["session.set.0.2"].label, "Set 3 · Reps: 7")
        app.terminate()
        app.launch()
        tap("workout.edit.E2E Workout")
        XCTAssertTrue(app.staticTexts["Sets: 2 · Reps: 12 · Rest: 45 sec"].waitForExistence(timeout: 10))
    }

    private func showSetActions() {
        let add = app.buttons["active.set.add"]
        for _ in 0..<6 where !add.isHittable { app.swipeUp() }
        XCTAssertTrue(add.isHittable)
        XCTAssertTrue(app.buttons["active.set.removeLast"].isHittable)
    }
}
