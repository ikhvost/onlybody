import XCTest

@MainActor
extension NativeDesignReviewTests {
    func testActiveSetMotion() {
        continueAfterFailure = false
        setReduceMotion(false)
        reviewSetMotion()
    }

    func testActiveSetMotionWithReduceMotion() {
        continueAfterFailure = false
        restoresReduceMotion = true
        setReduceMotion(true)
        reviewSetMotion()
    }

    private func reviewSetMotion() {
        continueAfterFailure = false
        let app = XCUIApplication()
        app.launchArguments = ["-AppleLanguages", "(en)", "-AppleLocale", "en_US"]
        app.launchEnvironment["ONLYBODY_DESIGN_REVIEW"] = "1"
        app.launchEnvironment["ONLYBODY_UI_STORE"] = UUID().uuidString
        // Keep animations enabled in the gallery, including the normal-motion review.
        app.launchEnvironment["ONLYBODY_REDUCED_MATERIALS"] = "0"
        app.launch()
        defer { app.terminate() }
        XCTAssertTrue(app.buttons["designReview.next"].waitForExistence(timeout: 10))
        for index in 0..<7 { advance(app, from: index) }
        let add = app.buttons["active.set.add"]
        let remove = app.buttons["active.set.removeLast"]
        for _ in 0..<6 where !add.isHittable { app.swipeUp() }
        for _ in 0..<2 { remove.tap() }
        XCTAssertFalse(remove.isEnabled)
        // Repeated changes while the entire list fits, then past the scroll boundary.
        for _ in 0..<2 { add.tap(); assertSetActionsAligned(add, remove); remove.tap() }
        for index in 1...7 {
            add.tap()
            assertSetActionsAligned(add, remove)
            XCTAssertTrue(app.textFields["active.set.\(index).reps"].isHittable)
        }
        add.tap()
        XCTAssertTrue(app.textFields["active.set.8.reps"].isHittable)
        assertSetActionsAligned(add, remove)
        app.buttons["active.set.8.done"].tap()
        // The rest timer reduces the viewport after checking a set.
        for _ in 0..<6 where !add.isHittable { app.swipeUp() }
        XCTAssertFalse(remove.isEnabled)
        app.buttons["active.set.8.done"].tap()
        for _ in 0..<8 { remove.tap(); assertSetActionsAligned(add, remove) }
        XCTAssertFalse(remove.isEnabled)
    }

    private func assertSetActionsAligned(_ add: XCUIElement, _ remove: XCUIElement) {
        let aligned = NSPredicate { _, _ in
            add.isHittable && remove.isHittable && abs(add.frame.midY - remove.frame.midY) < 1
        }
        if !aligned.evaluate(with: nil) {
            XCTAssertEqual(XCTWaiter.wait(for: [XCTNSPredicateExpectation(predicate: aligned, object: nil)], timeout: 3), .completed)
        }
    }

    func setReduceMotion(_ enabled: Bool) {
        let settings = XCUIApplication(bundleIdentifier: "com.apple.Preferences")
        settings.launch()
        defer { settings.terminate() }
        let toggle = settings.switches["Reduce Motion"]
        if !toggle.exists {
            let accessibility = settings.staticTexts["Accessibility"].firstMatch
            for _ in 0..<8 where !accessibility.isHittable { settings.swipeUp() }
            XCTAssertTrue(accessibility.isHittable)
            accessibility.tap()
            settings.staticTexts["Motion"].tap()
        }
        XCTAssertTrue(toggle.waitForExistence(timeout: 5))
        if (toggle.value as? String == "1") != enabled {
            toggle.coordinate(withNormalizedOffset: CGVector(dx: 0.9, dy: 0.5)).tap()
        }
        let expected = NSPredicate(format: "value == %@", enabled ? "1" : "0")
        XCTAssertEqual(XCTWaiter.wait(for: [XCTNSPredicateExpectation(predicate: expected, object: toggle)], timeout: 5), .completed)
    }
}
