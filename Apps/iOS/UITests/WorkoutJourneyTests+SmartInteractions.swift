import XCTest

/// Regressions for shared controls and step-aware back gestures in Smart Selection.
extension WorkoutJourneyTests {
    func testSmartBackGesturesAndKeyboardDismissal() {
        tap("workout.create")
        tap("creation.smart")
        XCTAssertTrue(app.buttons["smart.continue"].waitForExistence(timeout: 10))
        XCTAssertFalse(app.buttons["picker.build"].exists)
        let target = app.buttons["smart.target.Chest"]
        for _ in 0..<5 where !target.isHittable { app.swipeUp() }
        tap("smart.target.Chest")
        let back = app.buttons["smart.back"]
        XCTAssertTrue(back.waitForExistence(timeout: 10))
        XCTAssertGreaterThanOrEqual(back.frame.width, 44)
        XCTAssertGreaterThanOrEqual(back.frame.height, 44)
        let name = app.textFields["smart.name"]
        for _ in 0..<8 where !name.isHittable { app.swipeUp() }
        XCTAssertTrue(name.isHittable)
        name.tap()
        name.typeText("Smart Interactions")
        XCTAssertTrue(app.keyboards.firstMatch.waitForExistence(timeout: 5))
        let label = app.staticTexts["smart.name.label"]
        XCTAssertTrue(label.isHittable)
        // Blank space beside the label must dismiss the keyboard without activating another control.
        app.coordinate(withNormalizedOffset: .zero)
            .withOffset(CGVector(dx: app.frame.width - 22, dy: label.frame.midY)).tap()
        let hidden = XCTNSPredicateExpectation(predicate: NSPredicate(format: "exists == false"), object: app.keyboards.firstMatch)
        XCTAssertEqual(XCTWaiter.wait(for: [hidden], timeout: 5), .completed)
        tap("smart.continue")
        XCTAssertTrue(app.buttons["smart.preview"].waitForExistence(timeout: 5))
        let foot = app.buttons["smart.region.foot"]
        let hip = app.buttons["smart.region.hip"]
        tap("smart.region.foot")
        tap("smart.region.hip")
        XCTAssertTrue(foot.isSelected)
        XCTAssertTrue(hip.isSelected)
        tap("smart.region.hip")
        XCTAssertTrue(foot.isSelected)
        XCTAssertFalse(hip.isSelected)
        tap("smart.region.hip")
        smartSwipeBack()
        XCTAssertTrue(app.buttons["smart.continue"].waitForExistence(timeout: 5))
        XCTAssertFalse(app.alerts.firstMatch.exists)
        tap("smart.continue")
        XCTAssertTrue(foot.isSelected)
        XCTAssertTrue(hip.isSelected)
        tap("smart.back")
        XCTAssertTrue(app.buttons["smart.continue"].waitForExistence(timeout: 5))
        tap("smart.back")
        XCTAssertTrue(app.alerts.firstMatch.waitForExistence(timeout: 5))
        tap("Stay")
        tap("smart.continue")
        tap("smart.preview")
        XCTAssertTrue(app.buttons["smart.save"].waitForExistence(timeout: 5))
        smartSwipeBack()
        XCTAssertTrue(app.buttons["smart.preview"].waitForExistence(timeout: 5))
        tap("smart.preview")
        verifySmartReplacementBack()
        if app.buttons["smart.acceptShortPlan"].exists { tap("smart.acceptShortPlan") }
        tap("smart.save")
        tap("workout.start.Smart Interactions")
        XCTAssertTrue(app.buttons["smart.start"].waitForExistence(timeout: 5))
        // A saved, unchanged preview should pop normally, without a discard confirmation.
        smartSwipeBack()
        XCTAssertTrue(app.buttons["workout.start.Smart Interactions"].waitForExistence(timeout: 5))
        XCTAssertFalse(app.alerts.firstMatch.exists)
        app.terminate()
        app.launch()
        tap("workout.edit.Smart Interactions")
        tap("smart.continue")
        XCTAssertTrue(foot.isSelected)
        XCTAssertTrue(hip.isSelected)
    }

    func testSmartMovementEditingUsesDraftAndPreservesDailyValues() {
        tap("workout.create")
        tap("creation.smart")
        let target = app.buttons["smart.target.Chest"]
        for _ in 0..<5 where !target.isHittable { app.swipeUp() }
        tap("smart.target.Chest")
        let name = app.textFields["smart.name"]
        for _ in 0..<5 where !name.isHittable { app.swipeUp() }
        name.tap()
        name.typeText("Smart Edit")
        tap("smart.continue")
        tap("smart.preview")
        XCTAssertTrue(app.staticTexts["smart.preview.name"].waitForExistence(timeout: 10))
        XCTAssertEqual(app.staticTexts["smart.preview.name"].label, "Smart Edit")
        let movement = app.buttons.matching(NSPredicate(format: "identifier BEGINSWITH %@", "smart.movement.")).firstMatch
        for _ in 0..<5 where !movement.isHittable { app.swipeUp() }
        XCTAssertTrue(movement.isHittable)
        let movementID = movement.identifier
        movement.tap()
        let reps = app.textFields["stepper.Reps.value"]
        XCTAssertTrue(reps.waitForExistence(timeout: 5))
        let original = reps.value as? String
        tap("stepper.Reps.decrease")
        tap("smart.movement.cancel")
        tap(movementID)
        XCTAssertTrue(reps.waitForExistence(timeout: 5))
        XCTAssertEqual(reps.value as? String, original)
        tap("stepper.Reps.decrease")
        let edited = reps.value as? String
        tap("smart.movement.done")
        if app.buttons["smart.acceptShortPlan"].exists { tap("smart.acceptShortPlan") }
        tap("smart.save")
        app.terminate()
        app.launch()
        tap("workout.start.Smart Edit")
        let reopened = app.buttons[movementID]
        for _ in 0..<5 where !reopened.isHittable { app.swipeUp() }
        tap(movementID)
        XCTAssertTrue(reps.waitForExistence(timeout: 5))
        XCTAssertEqual(reps.value as? String, edited)
    }

    func testSmartTargetsAreExclusiveAndLimitedToThree() {
        tap("workout.create")
        tap("creation.smart")
        for name in ["Chest", "Back", "Shoulders"] {
            let chip = app.buttons["smart.target.\(name)"]
            for _ in 0..<5 where !chip.isHittable { app.swipeUp() }
            tap("smart.target.\(name)")
        }
        XCTAssertFalse(app.buttons["smart.target.Biceps"].isEnabled)
        XCTAssertTrue(app.buttons["smart.target.Chest"].isEnabled)
        let fullBody = app.buttons["smart.target.Full Body"]
        for _ in 0..<5 where !fullBody.isHittable { app.swipeUp() }
        tap("smart.target.Full Body")
        XCTAssertTrue(fullBody.isSelected)
        XCTAssertFalse(app.buttons["smart.target.Chest"].isSelected)
        let chest = app.buttons["smart.target.Chest"]
        for _ in 0..<5 where !chest.isHittable { app.swipeDown() }
        tap("smart.target.Chest")
        XCTAssertTrue(chest.isSelected)
        XCTAssertFalse(fullBody.isSelected)
        XCTAssertTrue(app.buttons["smart.target.Biceps"].isEnabled)
    }

    func testSmartDailyReorderingSurvivesReopening() {
        tap("workout.create")
        tap("creation.smart")
        let fullBody = app.buttons["smart.target.Full Body"]
        for _ in 0..<5 where !fullBody.isHittable { app.swipeUp() }
        tap("smart.target.Full Body")
        let name = app.textFields["smart.name"]
        for _ in 0..<5 where !name.isHittable { app.swipeUp() }
        name.tap()
        name.typeText("Smart Order")
        tap("smart.continue")
        tap("smart.preview")
        let handles = app.descendants(matching: .any).matching(NSPredicate(format: "identifier BEGINSWITH %@", "smart.drag."))
        let first = handles.element(boundBy: 0)
        let second = handles.element(boundBy: 1)
        XCTAssertTrue(second.waitForExistence(timeout: 10))
        for _ in 0..<5 where !second.isHittable { app.swipeUp() }
        let firstID = first.identifier
        let secondID = second.identifier
        let destination = second.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5)).withOffset(CGVector(dx: 0, dy: 20))
        first.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5))
            .press(forDuration: 0.7, thenDragTo: destination, withVelocity: .slow, thenHoldForDuration: 1)
        let reordered = NSPredicate { [self] _, _ in
            app.descendants(matching: .any).matching(identifier: firstID).firstMatch.frame.midY
                > app.descendants(matching: .any).matching(identifier: secondID).firstMatch.frame.midY
        }
        expectation(for: reordered, evaluatedWith: app)
        waitForExpectations(timeout: 5)
        if app.buttons["smart.acceptShortPlan"].exists { tap("smart.acceptShortPlan") }
        tap("smart.save")
        tap("workout.start.Smart Order")
        XCTAssertTrue(app.buttons["smart.start"].waitForExistence(timeout: 10))
        XCTAssertEqual(handles.element(boundBy: 0).identifier, secondID)
        XCTAssertEqual(handles.element(boundBy: 1).identifier, firstID)
        XCTAssertFalse(app.staticTexts["Main"].exists)
        XCTAssertFalse(app.staticTexts["Additional"].exists)
    }

    private func verifySmartReplacementBack() {
        let replace = app.buttons.matching(NSPredicate(format: "identifier BEGINSWITH %@", "smart.replace.")).firstMatch
        for _ in 0..<5 where !replace.isHittable { app.swipeUp() }
        XCTAssertTrue(replace.isHittable)
        replace.tap()
        XCTAssertTrue(app.textFields["exercisePicker.search"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.buttons["exercisePicker.close"].exists)
        if app.staticTexts["exercisePicker.empty"].exists {
            XCTAssertFalse(app.buttons["exercisePicker.clearFilters"].exists)
        }
        XCTAssertFalse(app.buttons["smartReplacement.another"].exists)
        smartSwipeBack()
        XCTAssertTrue(app.buttons["smart.save"].waitForExistence(timeout: 5))
        XCTAssertFalse(app.buttons["exercisePicker.close"].exists)
    }

    private func smartSwipeBack() {
        let start = app.coordinate(withNormalizedOffset: CGVector(dx: 0, dy: 0.5)).withOffset(CGVector(dx: 56, dy: 0))
        let end = app.coordinate(withNormalizedOffset: CGVector(dx: 0.88, dy: 0.5))
        start.press(forDuration: 0.05, thenDragTo: end)
    }
}
