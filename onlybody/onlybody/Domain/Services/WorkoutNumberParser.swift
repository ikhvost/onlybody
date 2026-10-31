import Foundation

/// Strict, locale-aware parsing for editable workout quantities. No partial parsing or clamping.
nonisolated struct WorkoutNumberParser {
    func integer(_ text: String, minimum: Int) -> Int? {
        guard !text.isEmpty, text.allSatisfy({ $0.isASCII && $0.isNumber }),
              let value = Int(text), value >= minimum, value <= Int(Int32.max) else { return nil }
        return value
    }

    func weight(_ text: String, locale: Locale = .current) -> Double? {
        let separator = locale.decimalSeparator ?? "."
        let normalized = text.replacing(separator, with: ".")
        let pieces = normalized.split(separator: ".", omittingEmptySubsequences: false)
        guard (1...2).contains(pieces.count), !pieces[0].isEmpty,
              pieces.allSatisfy({ !$0.isEmpty && $0.allSatisfy { $0.isASCII && $0.isNumber } }),
              pieces.count == 1 || pieces[1].count <= 2,
              let value = Double(normalized), value.isFinite, value >= 0, value <= Double(Int32.max) else { return nil }
        return value
    }
}
