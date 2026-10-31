import XCTest

/// Real simulator captures: SwiftUI ScrollViews, native controls, and process-level language selection.
@MainActor
final class NativeDesignReviewTests: XCTestCase {
    func testNativeScreenMatrix() {
        continueAfterFailure = false
        for (language, locale) in [("uk", "uk_UA"), ("en", "en_US"), ("pl", "pl_PL"), ("de", "de_DE"), ("fr", "fr_FR")] {
            let app = XCUIApplication()
            app.launchArguments = ["-AppleLanguages", "(\(language))", "-AppleLocale", locale]
            app.launchEnvironment["ONLYBODY_DESIGN_REVIEW"] = "1"
            app.launchEnvironment["ONLYBODY_UI_STORE"] = UUID().uuidString
            app.launch()
            for index in 0..<20 {
                let counter = app.staticTexts["designReview.index"]
                if !counter.exists || counter.label != String(index) {
                    let expected = NSPredicate(format: "label == %@", String(index))
                    expectation(for: expected, evaluatedWith: counter)
                    waitForExpectations(timeout: 10)
                }
                let screenshot = XCTAttachment(screenshot: app.screenshot())
                screenshot.name = "v002-\(JourneyProduct.name)-\(Int(app.frame.width))-\(language)-\(index)"
                screenshot.lifetime = .keepAlways
                add(screenshot)
                advance(app, from: index)
            }
            app.terminate()
        }
    }
    func testCustomControlHitAreas() {
        continueAfterFailure = false
        let app = XCUIApplication()
        app.launchArguments = ["-AppleLanguages", "(en)", "-AppleLocale", "en_US"]
        app.launchEnvironment["ONLYBODY_DESIGN_REVIEW"] = "1"
        app.launchEnvironment["ONLYBODY_UI_STORE"] = UUID().uuidString
        app.launch()
        defer { app.terminate() }
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
                assertHitArea(app.buttons["builder.save"], minimum: 56)
            }
            if index == 7 {
                assertHitArea(app.buttons["active.markSetDone"], minimum: 64)
                assertHitArea(app.buttons["stepper.Reps.increase"], minimum: 48)
            }
            app.buttons["designReview.next"].tap()
        }
    }

    private func advance(_ app: XCUIApplication, from index: Int) {
        let counter = app.staticTexts["designReview.index"]
        let next = NSPredicate(format: "label == %@", String((index + 1) % 20))
        for _ in 0..<3 {
            app.buttons["designReview.next"].tap()
            if XCTWaiter.wait(for: [XCTNSPredicateExpectation(predicate: next, object: counter)], timeout: 2) == .completed { return }
            XCTAssertEqual(counter.label, String(index), "Gallery must advance one state at a time")
        }
        XCTFail("Gallery did not advance after bounded retries: \(index)")
    }

    private func assertHitArea(_ button: XCUIElement, minimum: CGFloat) {
        XCTAssertTrue(button.exists, button.identifier)
        XCTAssertGreaterThanOrEqual(button.frame.width + 0.5, minimum, button.identifier)
        XCTAssertGreaterThanOrEqual(button.frame.height + 0.5, minimum, button.identifier)
    }

}
