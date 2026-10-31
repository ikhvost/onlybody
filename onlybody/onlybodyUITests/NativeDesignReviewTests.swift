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
                app.buttons["designReview.next"].tap()
            }
            app.terminate()
        }
    }
}
