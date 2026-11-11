import XCTest

/// Numeric replacement exercises the actual focus lifecycle shared by both products.
extension WorkoutJourneyTests {
    func testEditorRepetitionsReplaceRestoreAndPersist() {
        createWorkout()
        tap("workout.edit.E2E Workout")
        let movement = app.buttons.matching(NSPredicate(format: "identifier BEGINSWITH %@", "builder.movement.")).firstMatch
        tap(movement.identifier)
        let reps = app.textFields["stepper.Reps.value"]
        XCTAssertTrue(reps.waitForExistence(timeout: 5))
        verifyRepetitionReplacement(reps)
        reps.tap()
        expectEmpty(reps)
        tap("stepper.Reps.increase")
        XCTAssertEqual(reps.value as? String, "13")
        let sets = app.textFields["stepper.Sets.value"]
        sets.tap()
        XCTAssertEqual(sets.value as? String, "1")
        dismissNumberKeyboard(at: "number.Sets.title")
        let rest = app.textFields["stepper.Rest.value"]
        for _ in 0..<4 where !rest.isHittable { app.swipeUp() }
        rest.tap()
        XCTAssertEqual(rest.value as? String, "45")
        dismissNumberKeyboard(at: "number.Rest.title")
        for _ in 0..<4 where !reps.isHittable { app.swipeDown() }
        reps.tap()
        reps.typeText("8")
        tap("builder.movement.done")
        tap("builder.save")
        app.terminate()
        app.launch()
        tap("workout.edit.E2E Workout")
        XCTAssertTrue(app.staticTexts["Sets: 1 · Reps: 8 · Rest: 45 sec"].waitForExistence(timeout: 5))
        tap(movement.identifier)
        XCTAssertTrue(reps.waitForExistence(timeout: 5))
        reps.tap()
        expectEmpty(reps)
        tap("builder.movement.done")
        tap("builder.save")
        XCTAssertTrue(app.buttons["workout.start.E2E Workout"].waitForExistence(timeout: 5))
    }

    func testSessionNumbersReplaceBeforeStartAndPersistAfterCompletion() {
        createWorkout(sets: 2)
        tap("workout.overview.E2E Workout")
        tap("active.exercise.0")
        let reps = app.textFields["active.set.0.reps"]
        XCTAssertTrue(reps.waitForExistence(timeout: 5))
        verifyRepetitionReplacement(reps)
        reps.tap()
        reps.typeText("9")
        tap("active.list")
        tap("active.start")
        XCTAssertEqual(reps.value as? String, "9")
        if app.buttons["active.addWeight"].exists { tap("active.addWeight") }
        let weight = app.textFields["active.set.0.weight"]
        weight.tap()
        expectEmpty(weight)
        weight.typeText("25.5")
        reps.tap()
        expectEmpty(reps)
        XCTAssertEqual(weight.value as? String, "25.5")
        reps.typeText("7")
        weight.tap()
        expectEmpty(weight)
        weight.typeText("8" + XCUIKeyboardKey.delete.rawValue)
        expectEmpty(weight)
        tap("active.set.0.done")
        tap("rest.skip")
        XCTAssertEqual(weight.value as? String, "25.5")
        XCTAssertEqual(reps.value as? String, "7")
        tap("active.list")
        tap("active.end")
        tap("End & Save")
        tap("active.close")
        tap("tab.log")
        tap("session.row")
        XCTAssertEqual(app.staticTexts["session.set.0.0"].label, "Set 1 · Reps: 7")
        XCTAssertTrue(app.staticTexts["session.weight.0.0"].label.contains("25.5 kg"))
    }

    /// Shared with the daily Smart editor check: no typing and erased typing both restore the original.
    func verifyRepetitionReplacement(_ field: XCUIElement) {
        let original = field.value as? String
        let outside = field.identifier.hasPrefix("active.") ? "active.elapsed" : "number.Reps.title"
        field.tap()
        expectEmpty(field)
        dismissNumberKeyboard(at: outside)
        XCTAssertEqual(field.value as? String, original)
        field.tap()
        expectEmpty(field)
        field.typeText("8")
        field.coordinate(withNormalizedOffset: CGVector(dx: 0.95, dy: 0.5)).tap()
        XCTAssertEqual(field.value as? String, "8")
        field.typeText(XCUIKeyboardKey.delete.rawValue)
        expectEmpty(field)
        dismissNumberKeyboard(at: outside)
        XCTAssertEqual(field.value as? String, original)
    }

    private func expectEmpty(_ field: XCUIElement) {
        let empty = NSPredicate { _, _ in
            let value = field.value as? String ?? ""
            return value.isEmpty || value == field.placeholderValue
        }
        let cleared = XCTNSPredicateExpectation(predicate: empty, object: field)
        XCTAssertEqual(XCTWaiter.wait(for: [cleared], timeout: 5), .completed, "Expected empty input: \(field.debugDescription)")
    }

    private func dismissNumberKeyboard(at identifier: String) {
        let label = app.staticTexts[identifier]
        XCTAssertTrue(label.waitForExistence(timeout: 5))
        label.tap()
        let hidden = XCTNSPredicateExpectation(predicate: NSPredicate(format: "exists == false"), object: app.keyboards.firstMatch)
        XCTAssertEqual(XCTWaiter.wait(for: [hidden], timeout: 5), .completed)
    }
}
