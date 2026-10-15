import Foundation

/// Role: Furrow. American checkers. You sit at the bottom and move up. House sits at the top.
enum CheckersSide: String, Codable, Equatable, Sendable {
    case player
    case house

    var other: CheckersSide { self == .player ? .house : .player }
}

struct CheckersMan: Codable, Equatable, Sendable {
    var side: CheckersSide
    var king: Bool
}

struct CheckersMove: Equatable, Hashable, Sendable {
    var from: Int
    var to: Int
    var jumped: Int?
}

struct CheckersMatch: Codable, Equatable, Sendable {
    var men: [CheckersMan?]
    var turn: CheckersSide
    var lock: Int?
    var winner: CheckersSide?

    static func opening() -> CheckersMatch {
        var men = Array<CheckersMan?>(repeating: nil, count: 64)
        for index in 0..<64 where CheckersBoard.dark(index) {
            let rank = CheckersBoard.rank(index)
            if rank <= 2 {
                men[index] = CheckersMan(side: .player, king: false)
            } else if rank >= 5 {
                men[index] = CheckersMan(side: .house, king: false)
            }
        }
        return CheckersMatch(men: men, turn: .player, lock: nil, winner: nil)
    }
}

enum CheckersBoard {
    static func index(_ file: Int, _ rank: Int) -> Int { rank * 8 + file }
    static func file(_ index: Int) -> Int { index % 8 }
    static func rank(_ index: Int) -> Int { index / 8 }
    static func dark(_ index: Int) -> Bool { (file(index) + rank(index)).isMultiple(of: 2) == false }
    static func onBoard(_ file: Int, _ rank: Int) -> Bool {
        (0..<8).contains(file) && (0..<8).contains(rank)
    }
}

/// Role: Furrow. Quiet steps, forced jumps, kings, and a house reply.
enum CheckersRules {
    static func legal(_ match: CheckersMatch) -> [CheckersMove] {
        guard match.winner == nil else { return [] }
        let jumps = jumpMoves(match)
        if jumps.isEmpty == false { return jumps }
        if match.lock != nil { return [] }
        return quietMoves(match)
    }

    static func after(_ match: CheckersMatch, _ move: CheckersMove) -> CheckersMatch {
        guard legal(match).contains(move), var man = match.men[move.from] else { return match }
        var next = match
        next.men[move.from] = nil
        if let jumped = move.jumped {
            next.men[jumped] = nil
        }
        let destRank = CheckersBoard.rank(move.to)
        let promoted = man.king == false && backRank(man.side, destRank)
        if promoted { man.king = true }
        next.men[move.to] = man
        if move.jumped != nil, promoted == false, jumpsFrom(next, index: move.to).isEmpty == false {
            next.lock = move.to
            next.turn = man.side
            return next
        }
        next.lock = nil
        next.turn = man.side.other
        if legal(next).isEmpty {
            next.winner = man.side
        }
        return next
    }

    static func houseChoice(_ match: CheckersMatch) -> CheckersMove? {
        guard match.turn == .house, match.winner == nil else { return nil }
        return legal(match).max { lhs, rhs in
            let left = score(lhs, match)
            let right = score(rhs, match)
            if left != right { return left < right }
            if lhs.to != rhs.to { return lhs.to > rhs.to }
            return lhs.from > rhs.from
        }
    }

    private static func score(_ move: CheckersMove, _ match: CheckersMatch) -> Int {
        var value = 0
        if move.jumped != nil { value += 20 }
        guard let man = match.men[move.from] else { return value }
        let rank = CheckersBoard.rank(move.to)
        if man.king == false, backRank(.house, rank) { value += 15 }
        value += 7 - rank
        return value
    }

    private static func backRank(_ side: CheckersSide, _ rank: Int) -> Bool {
        side == .player ? rank == 7 : rank == 0
    }

    private static func quietMoves(_ match: CheckersMatch) -> [CheckersMove] {
        var moves: [CheckersMove] = []
        for index in match.men.indices {
            guard let man = match.men[index], man.side == match.turn else { continue }
            for step in steps(man) {
                let file = CheckersBoard.file(index) + step.0
                let rank = CheckersBoard.rank(index) + step.1
                guard CheckersBoard.onBoard(file, rank) else { continue }
                let dest = CheckersBoard.index(file, rank)
                if match.men[dest] == nil {
                    moves.append(CheckersMove(from: index, to: dest, jumped: nil))
                }
            }
        }
        return moves
    }

    private static func jumpMoves(_ match: CheckersMatch) -> [CheckersMove] {
        if let lock = match.lock {
            return jumpsFrom(match, index: lock)
        }
        var moves: [CheckersMove] = []
        for index in match.men.indices {
            guard let man = match.men[index], man.side == match.turn else { continue }
            moves.append(contentsOf: jumpsFrom(match, index: index))
        }
        return moves
    }

    private static func jumpsFrom(_ match: CheckersMatch, index: Int) -> [CheckersMove] {
        guard let man = match.men[index] else { return [] }
        var moves: [CheckersMove] = []
        for step in steps(man) {
            let midFile = CheckersBoard.file(index) + step.0
            let midRank = CheckersBoard.rank(index) + step.1
            let landFile = midFile + step.0
            let landRank = midRank + step.1
            guard CheckersBoard.onBoard(landFile, landRank) else { continue }
            let mid = CheckersBoard.index(midFile, midRank)
            let land = CheckersBoard.index(landFile, landRank)
            guard let blocked = match.men[mid], blocked.side != man.side, match.men[land] == nil else { continue }
            moves.append(CheckersMove(from: index, to: land, jumped: mid))
        }
        return moves
    }

    private static func steps(_ man: CheckersMan) -> [(Int, Int)] {
        let forward = man.side == .player ? 1 : -1
        if man.king {
            return [(1, 1), (1, -1), (-1, 1), (-1, -1)]
        }
        return [(1, forward), (-1, forward)]
    }
}
