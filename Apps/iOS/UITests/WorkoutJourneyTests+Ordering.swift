import XCTest

/// Ordering checks shared by the editor and the active-session journey.
extension WorkoutJourneyTests {
    func verifyEditorReordering() {
        let rows = app.buttons.matching(NSPredicate(format: "identifier BEGINSWITH %@", "builder.movement."))
        let first = rows.element(boundBy: 0)
        let second = rows.element(boundBy: 1)
        let firstID = first.identifier
        let secondID = second.identifier
        let down = firstID.replacing("builder.movement.", with: "builder.order.") + ".down"
        let up = firstID.replacing("builder.movement.", with: "builder.order.") + ".up"
        tap(firstID.replacing("builder.movement.", with: "builder.order.") + ".menu")
        tap(down)
        assertRowOrder(firstID, secondID, firstBelow: true)
        tap(firstID.replacing("builder.movement.", with: "builder.order.") + ".menu")
        tap(up)
        assertRowOrder(firstID, secondID, firstBelow: false)
        let firstHandle = firstID.replacing("builder.movement.", with: "builder.drag.")
        let secondHandle = secondID.replacing("builder.movement.", with: "builder.drag.")
        dragExercise(firstHandle, to: secondHandle, extraDistance: 30)
        assertRowOrder(firstID, secondID, firstBelow: true)
        dragExercise(firstHandle, to: secondHandle, extraDistance: -30)
        assertRowOrder(firstID, secondID, firstBelow: false)
    }

    private func assertRowOrder(_ firstID: String, _ secondID: String, firstBelow: Bool) {
        // Menu actions run after sheet dismissal, then the rows animate into place.
        let settled = NSPredicate { [self] _, _ in
            let firstY = app.buttons[firstID].frame.midY
            let secondY = app.buttons[secondID].frame.midY
            return firstBelow ? firstY > secondY : firstY < secondY
        }
        expectation(for: settled, evaluatedWith: app)
        waitForExpectations(timeout: 5)
    }

    func verifySessionDragReordering() {
        dragExercise("active.exercise.0.drag", to: "active.exercise.1.drag", extraDistance: 30)
        XCTAssertTrue(app.buttons["active.exercise.1"].label.contains(JourneyProduct.libraryExercise))
        dragExercise("active.exercise.1.drag", to: "active.exercise.0.drag", extraDistance: -30)
        XCTAssertTrue(app.buttons["active.exercise.0"].label.contains(JourneyProduct.libraryExercise))
    }

    private func dragExercise(_ sourceID: String, to targetID: String, extraDistance: CGFloat) {
        let source = app.descendants(matching: .any).matching(identifier: sourceID).firstMatch
        let target = app.descendants(matching: .any).matching(identifier: targetID).firstMatch
        XCTAssertTrue(source.waitForExistence(timeout: 5))
        XCTAssertTrue(target.waitForExistence(timeout: 5))
        let destination = target.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5))
            .withOffset(CGVector(dx: 0, dy: extraDistance))
        source.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5))
            .press(forDuration: 0.7, thenDragTo: destination, withVelocity: XCUIGestureVelocity(rawValue: 120), thenHoldForDuration: 1)
    }
}
