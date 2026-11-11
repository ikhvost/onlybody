import XCTest

/// Real simulator captures: SwiftUI ScrollViews, native controls, and process-level language selection.
@MainActor
final class NativeDesignReviewTests: XCTestCase {
    func testActiveSetControlsOnNarrowScreen() {
        continueAfterFailure = false
        let app = XCUIApplication()
        app.launchArguments = ["-AppleLanguages", "(en)", "-AppleLocale", "en_US"]
        app.launchEnvironment["ONLYBODY_DESIGN_REVIEW"] = "1"
        app.launchEnvironment["ONLYBODY_UI_STORE"] = UUID().uuidString
        app.launchEnvironment["ONLYBODY_REDUCED_MATERIALS"] = "1"
        app.launch()
        defer { app.terminate() }
        XCTAssertTrue(app.buttons["designReview.next"].waitForExistence(timeout: 10))
        for index in 0..<7 { advance(app, from: index) }
        if app.buttons["active.addWeight"].exists { app.buttons["active.addWeight"].tap() }
        let add = app.buttons["active.set.add"]
        for _ in 0..<6 where !add.isHittable { app.swipeUp() }
        XCTAssertTrue(add.isHittable)
        let remove = app.buttons["active.set.removeLast"]
        XCTAssertTrue(remove.isHittable && remove.isEnabled)
        XCTAssertLessThan(remove.frame.midX, add.frame.midX)
        for button in [add, remove] {
            XCTAssertGreaterThanOrEqual(button.frame.width, 44)
            XCTAssertGreaterThanOrEqual(button.frame.height, 44)
        }
        let screenshot = XCTAttachment(screenshot: app.screenshot())
        screenshot.name = "active-set-controls-\(JourneyProduct.name)-\(Int(app.frame.width))"
        screenshot.lifetime = .keepAlways
        self.add(screenshot)
        app.buttons["active.set.2.done"].tap()
        for _ in 0..<6 where !add.isHittable { app.swipeUp() }
        XCTAssertTrue(add.isHittable && add.isEnabled)
        XCTAssertFalse(remove.isEnabled)
        let completed = XCTAttachment(screenshot: app.screenshot())
        completed.name = "active-set-controls-completed-last-\(JourneyProduct.name)-\(Int(app.frame.width))"
        completed.lifetime = .keepAlways
        self.add(completed)
    }

    func testNativeScreenMatrix() {
        continueAfterFailure = false
        for (language, locale) in [("uk", "uk_UA"), ("en", "en_US"), ("pl", "pl_PL"), ("de", "de_DE"), ("fr", "fr_FR")] {
            capture(language: language, locale: locale)
        }
    }

    func testReducedMaterials() {
        continueAfterFailure = false
        capture(language: "en", locale: "en_US", reduced: true)
    }

    private func capture(language: String, locale: String, reduced: Bool = false) {
        let app = XCUIApplication()
        app.launchArguments = ["-AppleLanguages", "(\(language))", "-AppleLocale", locale]
        app.launchEnvironment["ONLYBODY_DESIGN_REVIEW"] = "1"
        app.launchEnvironment["ONLYBODY_UI_STORE"] = UUID().uuidString
        app.launchEnvironment["ONLYBODY_REDUCED_MATERIALS"] = reduced ? "1" : "0"
        app.launch()
        for index in 0..<20 {
            let counter = app.staticTexts["designReview.index"]
            if !counter.exists || counter.label != String(index) {
                let expected = NSPredicate(format: "label == %@", String(index))
                expectation(for: expected, evaluatedWith: counter)
                waitForExpectations(timeout: 10)
            }
            autoreleasepool {
                let screenshot = XCTAttachment(screenshot: app.screenshot())
                let mode = reduced ? "solid" : "glass"
                screenshot.name = "v006-\(JourneyProduct.name)-\(Int(app.frame.width))-\(language)-\(mode)-\(index)"
                screenshot.lifetime = .keepAlways
                add(screenshot)
            }
            advance(app, from: index)
        }
        app.terminate()
    }
    private func advance(_ app: XCUIApplication, from index: Int) {
        let counter = app.staticTexts["designReview.index"]
        let next = NSPredicate(format: "label == %@", String((index + 1) % 20))
        let expected = String((index + 1) % 20)
        for _ in 0..<3 {
            if counter.label == expected { return }
            app.buttons["designReview.next"].tap()
            if XCTWaiter.wait(for: [XCTNSPredicateExpectation(predicate: next, object: counter)], timeout: 5) == .completed { return }
            let actual = counter.label
            if actual == expected { return }
            XCTAssertEqual(actual, String(index), "Gallery must advance one state at a time")
        }
        XCTFail("Gallery did not advance after bounded retries: \(index)")
    }

}
