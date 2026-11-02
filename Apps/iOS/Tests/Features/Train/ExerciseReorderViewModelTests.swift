import CoreGraphics
import Foundation
import Testing
#if ONLYWEIGHTS
@testable import onlyweights
#else
@testable import onlybody
#endif

@MainActor struct ExerciseReorderViewModelTests {
    private let ids = [UUID(), UUID(), UUID()]

    @Test func liftWithoutMovingKeepsTheOriginalOrder() {
        let drag = makeDrag()
        drag.lift(ids[0])
        #expect(drag.liftedID == ids[0])
        #expect(drag.targetID == ids[0])
        #expect(drag.offset(for: ids[0], order: ids, spacing: 12) == 0)
        #expect(drag.finish() == nil)
        #expect(drag.liftedID == nil)
    }

    @Test func cardFollowsEveryFingerUpdateBeforeRelease() {
        let drag = makeDrag()
        drag.lift(ids[0])
        move(drag, id: ids[0], from: 130, to: 150)
        #expect(drag.offset(for: ids[0], order: ids, spacing: 12) == 20)
        #expect(drag.targetID == ids[0])
        move(drag, id: ids[0], from: 130, to: 160)
        #expect(drag.offset(for: ids[0], order: ids, spacing: 12) == 30)
    }

    @Test func crossingANeighborMovesItBeforeRelease() {
        let drag = makeDrag()
        drag.lift(ids[0])
        move(drag, id: ids[0], from: 130, to: 300)
        #expect(drag.liftedID == ids[0])
        #expect(drag.targetID == ids[1])
        #expect(drag.offset(for: ids[1], order: ids, spacing: 12) == -112)
        #expect(drag.offset(for: ids[2], order: ids, spacing: 12) == 0)
        let result = drag.finish()
        #expect(result?.source == ids[0])
        #expect(result?.target == ids[1])
        #expect(drag.finish() == nil)
    }

    @Test func upwardMoveUsesTheLiftedCardsHeight() {
        let drag = makeDrag()
        drag.lift(ids[1])
        move(drag, id: ids[1], from: 242, to: 100)
        #expect(drag.targetID == ids[0])
        #expect(drag.offset(for: ids[0], order: ids, spacing: 12) == 172)
        #expect(drag.offset(for: ids[1], order: ids, spacing: 12) == -142)
    }

    @Test func reversingTheDragRestoresTheGap() {
        let drag = makeDrag()
        drag.lift(ids[0])
        move(drag, id: ids[0], from: 130, to: 600)
        #expect(drag.targetID == ids[2])
        #expect(drag.offset(for: ids[2], order: ids, spacing: 12) == -112)
        move(drag, id: ids[0], from: 130, to: 130)
        #expect(drag.targetID == ids[0])
        #expect(drag.offset(for: ids[1], order: ids, spacing: 12) == 0)
        #expect(drag.finish() == nil)
    }

    @Test func cancellationDoesNotCommitThePreviewedMove() {
        let drag = makeDrag()
        drag.lift(ids[0])
        move(drag, id: ids[0], from: 130, to: 600)
        drag.cancel()
        #expect(drag.liftedID == nil)
        #expect(drag.fingerLocation == nil)
        #expect(drag.finish() == nil)
        #expect(drag.offset(for: ids[1], order: ids, spacing: 12) == 0)
    }

    @Test func scrollingKeepsTheCardUnderTheFinger() {
        let drag = makeDrag()
        drag.lift(ids[0])
        move(drag, id: ids[0], from: 130, to: 160)
        drag.updateFrame(CGRect(x: 20, y: 50, width: 335, height: 100), for: ids[0], order: ids)
        #expect(drag.offset(for: ids[0], order: ids, spacing: 12) == 80)
    }

    private func makeDrag() -> ExerciseReorderViewModel {
        let drag = ExerciseReorderViewModel()
        for (index, frame) in [CGRect(x: 20, y: 100, width: 335, height: 100),
                               CGRect(x: 20, y: 212, width: 335, height: 160),
                               CGRect(x: 20, y: 384, width: 335, height: 100)].enumerated() {
            drag.updateFrame(frame, for: ids[index], order: ids)
        }
        return drag
    }

    private func move(_ drag: ExerciseReorderViewModel, id: UUID, from startY: CGFloat, to endY: CGFloat) {
        drag.drag(id, start: CGPoint(x: 50, y: startY), location: CGPoint(x: 50, y: endY), order: ids)
    }
}
