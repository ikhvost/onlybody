import Foundation
import Testing
#if ONLYWEIGHTS
@testable import onlyweights
#else
@testable import onlybody
#endif

struct WorkoutNumberParserTests {
    let parser = WorkoutNumberParser()

    @Test func rejectsPartialOverflowAndInvalidIntegers() {
        for text in ["", " ", "-1", "+1", "1.5", "1e2", "999999999999999999999", "12x"] {
            #expect(parser.integer(text, minimum: 1) == nil)
        }
        #expect(parser.integer("0", minimum: 1) == nil)
        #expect(parser.integer("0", minimum: 0) == 0)
        #expect(parser.integer("15", minimum: 15) == 15)
    }

    @Test func parsesLocalDecimalsWithoutPartialOrNonfiniteValues() {
        #expect(parser.weight("12,25", locale: Locale(identifier: "uk_UA")) == 12.25)
        #expect(parser.weight("12.25", locale: Locale(identifier: "en_US")) == 12.25)
        for text in ["", "-1", "nan", "inf", "1e3", "1.001", "1.", "1,000.5", ".5"] {
            #expect(parser.weight(text, locale: Locale(identifier: "en_US")) == nil)
        }
    }
}
