import XCTest

/// The same editor, guides and unrestricted catalog are used by manual and daily Smart workouts.
extension WorkoutJourneyTests {
    func testSmartBackGesturesAndKeyboardDismissal() {
        tap("workout.create")
        tap("creation.smart")
        tap("smart.target.Chest")
        XCTAssertFalse(app.textFields["builder.name"].exists)
        tap("smart.continue")
        tap("smart.region.foot")
        tap("smart.region.hip")
        smartSwipeBack()
        XCTAssertTrue(app.buttons["smart.continue"].waitForExistence(timeout: 5))
        tap("smart.continue")
        XCTAssertTrue(app.buttons["smart.region.foot"].isSelected)
        XCTAssertTrue(app.buttons["smart.region.hip"].isSelected)
        tap("smart.preview")
        nameSmartDraft("Smart Interactions")
        tap("smart.edit")
        XCTAssertTrue(app.alerts.firstMatch.waitForExistence(timeout: 5))
        tap("Stay")
        XCTAssertTrue(app.textFields["builder.name"].exists)
        tap("builder.save")
        tap("workout.start.Smart Interactions")
        XCTAssertTrue(app.buttons["smart.start"].waitForExistence(timeout: 5))
        smartSwipeBack()
        XCTAssertTrue(app.buttons["workout.start.Smart Interactions"].waitForExistence(timeout: 5))
        XCTAssertFalse(app.alerts.firstMatch.exists)
        app.terminate()
        app.launch()
        tap("workout.edit.Smart Interactions")
        tap("smart.edit")
        tap("smart.continue")
        XCTAssertTrue(app.buttons["smart.region.foot"].isSelected)
        XCTAssertTrue(app.buttons["smart.region.hip"].isSelected)
    }

    func testSmartMovementEditingUsesDraftAndPreservesDailyValues() {
        openSmartDraft(target: "Chest", name: "Smart Edit")
        let movement = app.buttons.matching(NSPredicate(format: "identifier BEGINSWITH %@", "builder.movement.")).firstMatch
        XCTAssertTrue(movement.waitForExistence(timeout: 5))
        let movementID = movement.identifier
        tap(movementID)
        let reps = app.textFields["stepper.Reps.value"]
        XCTAssertTrue(reps.waitForExistence(timeout: 5))
        let original = reps.value as? String
        verifyRepetitionReplacement(reps)
        tap("stepper.Reps.decrease")
        tap("builder.movement.cancel")
        tap(movementID)
        XCTAssertTrue(reps.waitForExistence(timeout: 5))
        XCTAssertEqual(reps.value as? String, original)
        tap("stepper.Reps.decrease")
        let edited = reps.value as? String
        tap("builder.movement.guide")
        XCTAssertTrue(app.buttons["movement.back"].waitForExistence(timeout: 5))
        tap("movement.back")
        XCTAssertEqual(reps.value as? String, edited)
        tap("builder.movement.done")
        tap("builder.save")
        app.terminate()
        app.launch()
        tap("workout.start.Smart Edit")
        tap(movementID)
        XCTAssertTrue(reps.waitForExistence(timeout: 5))
        XCTAssertEqual(reps.value as? String, edited)
    }

    func testSmartCanReplaceAcrossMusclesAddAndRemoveForToday() {
        openSmartDraft(target: "Chest", name: "Smart Free")
        let replace = app.buttons.matching(NSPredicate(format: "identifier BEGINSWITH %@", "builder.replace.")).firstMatch
        XCTAssertTrue(replace.waitForExistence(timeout: 5))
        tap(replace.identifier)
        let search = app.textFields["exercisePicker.search"]
        XCTAssertTrue(search.waitForExistence(timeout: 5))
        XCTAssertEqual(search.value as? String, search.placeholderValue)
        search.tap()
        search.typeText(JourneyProduct.libraryExercise)
        tap("exercise.pick.\(JourneyProduct.libraryExercise)")
        XCTAssertFalse(app.buttons["smart.acceptShortPlan"].exists)
        XCTAssertTrue(app.buttons["smart.start"].isEnabled)
        tap("builder.add")
        XCTAssertTrue(search.waitForExistence(timeout: 5))
        search.tap()
        search.typeText(JourneyProduct.exercise)
        tap("exercise.pick.\(JourneyProduct.exercise)")
        let movements = app.buttons.matching(NSPredicate(format: "identifier BEGINSWITH %@", "builder.movement."))
        let count = movements.count
        let added = movements.element(boundBy: count - 1)
        for _ in 0..<6 where !added.isHittable || added.frame.maxY > app.buttons["builder.save"].frame.minY { app.swipeUp() }
        tap(added.identifier)
        tap("builder.movement.remove")
        XCTAssertTrue(app.alerts.firstMatch.waitForExistence(timeout: 5))
        app.alerts.buttons["Remove exercise"].tap()
        XCTAssertTrue(app.buttons["builder.save"].waitForExistence(timeout: 5))
        XCTAssertEqual(movements.count, count - 1)
        tap("builder.save")
        app.terminate()
        app.launch()
        tap("workout.start.Smart Free")
        XCTAssertEqual(movements.count, count - 1)
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
        openSmartDraft(target: "Full Body", name: "Smart Order")
        let handles = app.descendants(matching: .any).matching(NSPredicate(format: "identifier BEGINSWITH %@", "builder.drag."))
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
        tap("builder.save")
        tap("workout.start.Smart Order")
        XCTAssertTrue(app.buttons["smart.start"].waitForExistence(timeout: 10))
        XCTAssertEqual(handles.element(boundBy: 0).identifier, secondID)
        XCTAssertEqual(handles.element(boundBy: 1).identifier, firstID)
    }

    private func openSmartDraft(target: String, name: String) {
        tap("workout.create")
        tap("creation.smart")
        tap("smart.target.\(target)")
        tap("smart.continue")
        tap("smart.preview")
        nameSmartDraft(name)
    }

    private func nameSmartDraft(_ value: String) {
        let name = app.textFields["builder.name"]
        XCTAssertTrue(name.waitForExistence(timeout: 10))
        name.coordinate(withNormalizedOffset: CGVector(dx: 0.95, dy: 0.5)).tap()
        let old = name.value as? String ?? ""
        name.typeText(String(repeating: XCUIKeyboardKey.delete.rawValue, count: old.count) + value)
        let label = app.staticTexts["builder.name.label"]
        app.coordinate(withNormalizedOffset: .zero)
            .withOffset(CGVector(dx: app.frame.width - 22, dy: label.frame.midY)).tap()
        let hidden = XCTNSPredicateExpectation(predicate: NSPredicate(format: "exists == false"), object: app.keyboards.firstMatch)
        XCTAssertEqual(XCTWaiter.wait(for: [hidden], timeout: 5), .completed)
    }

    private func smartSwipeBack() {
        // Start outside reorder handles, whose horizontal drag belongs to exercise reordering.
        let start = app.coordinate(withNormalizedOffset: CGVector(dx: 0, dy: 0.3)).withOffset(CGVector(dx: 56, dy: 0))
        let end = app.coordinate(withNormalizedOffset: CGVector(dx: 0.88, dy: 0.3))
        start.press(forDuration: 0.05, thenDragTo: end)
    }
}
