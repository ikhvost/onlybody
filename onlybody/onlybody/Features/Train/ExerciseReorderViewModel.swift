import CoreGraphics
import Foundation
import Observation

/// Keeps drag presentation separate from the saved exercise order until release.
@MainActor @Observable final class ExerciseReorderViewModel {
    private(set) var liftedID: UUID?
    private(set) var targetID: UUID?
    private(set) var fingerLocation: CGPoint?
    private var grabOffset: CGFloat?
    private var frames: [UUID: CGRect] = [:]

    func updateFrame(_ frame: CGRect, for id: UUID, order: [UUID]) {
        frames[id] = frame
        updateTarget(order: order)
    }

    func lift(_ id: UUID) {
        guard liftedID == nil, frames[id] != nil else { return }
        liftedID = id
        targetID = id
    }

    func drag(_ id: UUID, start: CGPoint, location: CGPoint, order: [UUID]) {
        guard liftedID == id, let frame = frames[id] else { return }
        if grabOffset == nil { grabOffset = start.y - frame.minY }
        fingerLocation = location
        updateTarget(order: order)
    }

    func offset(for id: UUID, order: [UUID], spacing: CGFloat) -> CGFloat {
        guard let liftedID, let source = frames[liftedID] else { return 0 }
        if id == liftedID {
            guard let fingerLocation, let grabOffset else { return 0 }
            return fingerLocation.y - grabOffset - source.minY
        }
        guard let from = order.firstIndex(of: liftedID), let to = order.firstIndex(where: { $0 == targetID }),
              let index = order.firstIndex(of: id) else { return 0 }
        if from < index, index <= to { return -(source.height + spacing) }
        if to <= index, index < from { return source.height + spacing }
        return 0
    }

    /// Returns the intended move once; cancellation leaves the model order untouched.
    func finish() -> (source: UUID, target: UUID)? {
        let move: (source: UUID, target: UUID)?
        if let liftedID, let targetID, liftedID != targetID {
            move = (liftedID, targetID)
        } else {
            move = nil
        }
        cancel()
        return move
    }

    func cancel() {
        liftedID = nil
        targetID = nil
        fingerLocation = nil
        grabOffset = nil
    }

    private func updateTarget(order: [UUID]) {
        guard let liftedID, let source = frames[liftedID], let from = order.firstIndex(of: liftedID),
              let fingerLocation, let grabOffset else { return }
        let center = fingerLocation.y - grabOffset + source.height / 2
        var destination = from
        for index in order.indices {
            guard let frame = frames[order[index]] else { continue }
            if index > from, center >= frame.midY { destination = max(destination, index) }
            if index < from, center <= frame.midY { destination = min(destination, index) }
        }
        targetID = order[destination]
    }
}
