import XCTest

/// Functional hit-area checks, independent of the optional screenshot matrix.
@MainActor
final class ControlAccessibilityTests: XCTestCase {
    func testCustomControlHitAreas() {
        continueAfterFailure = false
        let app = XCUIApplication()
        app.launchArguments = ["-AppleLanguages", "(en)", "-AppleLocale", "en_US"]
        app.launchEnvironment["ONLYBODY_DESIGN_REVIEW"] = "1"
        app.launchEnvironment["ONLYBODY_UI_STORE"] = UUID().uuidString
        app.launch()
        defer {
            if (testRun?.failureCount ?? 0) > 0 {
                let screenshot = XCTAttachment(screenshot: app.screenshot())
                screenshot.lifetime = .keepAlways
                add(screenshot)
            }
            app.terminate()
        }
        for index in 0...7 {
            let counter = app.staticTexts["designReview.index"]
            if !counter.exists || counter.label != String(index) {
                expectation(for: NSPredicate(format: "label == %@", String(index)), evaluatedWith: counter)
                waitForExpectations(timeout: 10)
            }
            if index == 0 {
                assertHitArea(app.buttons["workout.create"], minimum: 44)
                assertHitArea(app.buttons["train.settings"], minimum: 44)
            }
            if index == 4 {
                assertHitArea(app.buttons["builder.back"], minimum: 44)
                assertHitArea(app.buttons["builder.add"], minimum: 44)
                assertHitArea(app.buttons["builder.options"], minimum: 44)
                assertHitArea(app.buttons["builder.save"], minimum: 52)
                assertHitArea(app.buttons.matching(NSPredicate(format: "identifier BEGINSWITH %@", "builder.replace.")).firstMatch, minimum: 44)
            }
            if index == 6 {
                assertHitArea(app.buttons["catalog.filters"], minimum: 44)
                assertHitArea(app.buttons.matching(NSPredicate(format: "identifier BEGINSWITH %@", "exercise.pick.")).firstMatch, minimum: 44)
                assertHitArea(app.buttons.matching(NSPredicate(format: "identifier BEGINSWITH %@", "exercise.guide.")).firstMatch, minimum: 44)
            }
            if index == 7 {
                assertHitArea(app.buttons["active.set.0.done"], minimum: 48)
                assertHitArea(app.textFields["active.set.0.reps"], minimum: 48)
            }
            app.buttons["designReview.next"].tap()
        }
    }

    private func assertHitArea(_ button: XCUIElement, minimum: CGFloat) {
        XCTAssertTrue(button.exists, button.identifier)
        XCTAssertGreaterThanOrEqual(button.frame.width + 0.5, minimum, button.identifier)
        XCTAssertGreaterThanOrEqual(button.frame.height + 0.5, minimum, button.identifier)
    }
}
