import Foundation
import Testing
@testable import onlybody

@MainActor
struct SessionDetailViewModelTests {
    @Test
    func dateLabelFormatsWeekdayMonthDayUppercased() {
        let session = Session()
        session.date = Calendar.current.date(from: DateComponents(year: 2026, month: 5, day: 1))!
        let viewModel = SessionDetailViewModel(session: session)

        let label = viewModel.dateLabel
        #expect(label == "FRIDAY, MAY 1")
    }

    @Test
    func dateLabelIsAlwaysUppercased() {
        let session = Session()
        session.date = Calendar.current.date(from: DateComponents(year: 2026, month: 1, day: 14))!
        let viewModel = SessionDetailViewModel(session: session)

        let label = viewModel.dateLabel
        #expect(label == "WEDNESDAY, JANUARY 14")
        // Verify uppercase by comparing to a lowercased version
        #expect(label == label.uppercased())
    }

    @Test
    func durationValueFormatsMinutesAndSeconds() {
        let session = Session()
        session.durationSeconds = 1450
        let viewModel = SessionDetailViewModel(session: session)

        #expect(viewModel.durationValue == "24:10")
    }

    @Test
    func durationValueZeroSecondsShowsZeroPadded() {
        let session = Session()
        session.durationSeconds = 120
        let viewModel = SessionDetailViewModel(session: session)

        #expect(viewModel.durationValue == "2:00")
    }

    @Test
    func durationValueZeroDuration() {
        let session = Session()
        session.durationSeconds = 0
        let viewModel = SessionDetailViewModel(session: session)

        #expect(viewModel.durationValue == "0:00")
    }

    @Test
    func durationUnitIsMin() {
        let session = Session()
        let viewModel = SessionDetailViewModel(session: session)

        #expect(viewModel.durationUnit == "min")
    }

    @Test
    func caloriesValueWithCalories() {
        let session = Session()
        session.caloriesBurned = 102
        let viewModel = SessionDetailViewModel(session: session)

        #expect(viewModel.caloriesValue == "102")
    }

    @Test
    func caloriesValueNilShowsEmDash() {
        let session = Session()
        session.caloriesBurned = nil
        let viewModel = SessionDetailViewModel(session: session)

        #expect(viewModel.caloriesValue == "\u{2014}")
    }

    @Test
    func caloriesUnitWithCalories() {
        let session = Session()
        session.caloriesBurned = 150
        let viewModel = SessionDetailViewModel(session: session)

        #expect(viewModel.caloriesUnit == "kcal")
    }

    @Test
    func caloriesUnitNil() {
        let session = Session()
        session.caloriesBurned = nil
        let viewModel = SessionDetailViewModel(session: session)

        #expect(viewModel.caloriesUnit == "")
    }

    @Test
    func sortedItemsOrdersByOrder() {
        let session = Session()

        let item2 = SessionItem()
        item2.order = 2
        item2.exerciseName = "Third"

        let item0 = SessionItem()
        item0.order = 0
        item0.exerciseName = "First"

        let item1 = SessionItem()
        item1.order = 1
        item1.exerciseName = "Second"

        session.items = [item2, item0, item1]

        let viewModel = SessionDetailViewModel(session: session)
        let sorted = viewModel.sortedItems

        #expect(sorted.count == 3)
        #expect(sorted[0].exerciseName == "First")
        #expect(sorted[1].exerciseName == "Second")
        #expect(sorted[2].exerciseName == "Third")
    }

    @Test
    func sortedItemsEmptyWhenItemsNil() {
        let session = Session()
        session.items = nil
        let viewModel = SessionDetailViewModel(session: session)

        #expect(viewModel.sortedItems.isEmpty)
    }

    @Test
    func totalRepsReturnsSumOfSetReps() {
        let item = SessionItem()
        item.setReps = [12, 12, 12]
        let viewModel = SessionDetailViewModel(session: Session())

        let total = viewModel.totalReps(for: item)
        #expect(total == 36)
    }

    @Test
    func totalRepsEmptySetRepsReturnsZero() {
        let item = SessionItem()
        item.setReps = []
        let viewModel = SessionDetailViewModel(session: Session())

        let total = viewModel.totalReps(for: item)
        #expect(total == 0)
    }

    @Test
    func setLabelFormatsIndexAndReps() {
        let viewModel = SessionDetailViewModel(session: Session())

        #expect(viewModel.setLabel(index: 0, reps: 12) == "SET 1 \u{00B7} 12 REPS")
        #expect(viewModel.setLabel(index: 1, reps: 8) == "SET 2 \u{00B7} 8 REPS")
        #expect(viewModel.setLabel(index: 2, reps: 10) == "SET 3 \u{00B7} 10 REPS")
    }

}
