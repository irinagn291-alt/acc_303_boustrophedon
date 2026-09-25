import Foundation

/// Role: Furrow. Artist XOR title with every other Stichos letter-reversed in place.
struct Furrow: Codable, Equatable, Sendable {
    var workId: String
    var field: FurrowField
    var stichoi: [Stichos]

    var remainingRetrograde: Int {
        stichoi.filter(\.isRetrograde).count
    }

    static func oxTurn(workId: String, field: FurrowField, line: String) -> Furrow? {
        let words = Stichos.tokens(in: line)
        guard words.count >= 2 else { return nil }
        let stichoi = words.enumerated().map { index, word in
            let odd = index % 2 == 1
            return Stichos(
                id: "\(workId).\(index)",
                index: index,
                catalog: word,
                shown: odd ? Stichos.letterReverse(word) : word,
                isRetrograde: odd,
                isCooled: false
            )
        }
        return Furrow(workId: workId, field: field, stichoi: stichoi)
    }

    func rights(index: Int) -> Furrow {
        var next = self
        guard next.stichoi.indices.contains(index) else { return next }
        next.stichoi[index].shown = next.stichoi[index].catalog
        next.stichoi[index].isRetrograde = false
        next.stichoi[index].isCooled = false
        return next
    }

    func unrights(index: Int) -> Furrow {
        var next = self
        guard next.stichoi.indices.contains(index) else { return next }
        let odd = index % 2 == 1
        next.stichoi[index].shown = odd ? Stichos.letterReverse(next.stichoi[index].catalog) : next.stichoi[index].catalog
        next.stichoi[index].isRetrograde = odd
        next.stichoi[index].isCooled = false
        return next
    }

    func cools(index: Int) -> Furrow {
        var next = self
        guard next.stichoi.indices.contains(index) else { return next }
        next.stichoi[index].isCooled = true
        return next
    }

    func reheats(index: Int) -> Furrow {
        var next = self
        guard next.stichoi.indices.contains(index) else { return next }
        next.stichoi[index].isCooled = false
        return next
    }
}
