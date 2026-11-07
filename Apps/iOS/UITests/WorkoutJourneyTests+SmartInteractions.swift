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

    private func verifySmartReplacementBack() {
        let replace = app.buttons.matching(NSPredicate(format: "identifier BEGINSWITH %@", "smart.replace.")).firstMatch
        for _ in 0..<5 where !replace.isHittable { app.swipeUp() }
        XCTAssertTrue(replace.isHittable)
        replace.tap()
        tap("smartReplacement.another")
        XCTAssertTrue(app.buttons["smartReplacement.back"].waitForExistence(timeout: 5))
        smartSwipeBack()
        XCTAssertTrue(app.buttons["smartReplacement.another"].waitForExistence(timeout: 5))
        smartSwipeBack()
        XCTAssertTrue(app.buttons["smart.save"].waitForExistence(timeout: 5))
        XCTAssertFalse(app.buttons["smartReplacement.close"].exists)
    }

    private func smartSwipeBack() {
        let start = app.coordinate(withNormalizedOffset: CGVector(dx: 0, dy: 0.5)).withOffset(CGVector(dx: 56, dy: 0))
        let end = app.coordinate(withNormalizedOffset: CGVector(dx: 0.88, dy: 0.5))
        start.press(forDuration: 0.05, thenDragTo: end)
    }
}
