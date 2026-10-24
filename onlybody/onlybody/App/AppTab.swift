enum AppTab: CaseIterable {
    case train
    case log
    case library

    var position: Int { Self.allCases.firstIndex(of: self) ?? 0 }

    func adjacent(forward: Bool) -> AppTab? {
        guard let index = Self.allCases.firstIndex(of: self) else { return nil }
        let next = index + (forward ? 1 : -1)
        return Self.allCases.indices.contains(next) ? Self.allCases[next] : nil
    }
}
