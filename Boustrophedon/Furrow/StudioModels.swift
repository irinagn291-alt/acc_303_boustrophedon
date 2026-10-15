import Foundation

/// Role: Furrow. Which job is fused on the open line. Face stays the home verb.
enum StudioTool: String, Codable, Equatable, Sendable {
    case face
    case plough
    case bench
    case cover
}

/// Role: Furrow. One word seated on the ox-plough reading course.
struct PloughCell: Codable, Equatable, Identifiable, Sendable {
    var id: String
    var tokenIndex: Int
    var word: String
    var row: Int
    var visualSlot: Int
}

/// Role: Furrow. Reading order is the catalog order. Odd rows sit right to left.
struct PloughCourse: Codable, Equatable, Sendable {
    var workId: String
    var field: FurrowField
    var cells: [PloughCell]
    var nextToken: Int
    var misses: Int
    var rowWidth: Int
}

/// Role: Furrow. A finished plough. The fold on the painting stays untouched.
struct PloughPass: Codable, Equatable, Identifiable, Sendable {
    var id: String
    var workId: String
    var field: FurrowField
    var seq: Int
    var daykey: Int
    var steps: Int
    var misses: Int
    var finished: Bool
}

/// Role: Furrow. One letter tile on the bench. Identity survives a repeated letter.
struct BenchTile: Codable, Equatable, Identifiable, Sendable {
    var id: String
    var letter: String
}

/// Role: Furrow. Spell the catalog word forward from a retrograde prompt.
struct BenchCourse: Codable, Equatable, Sendable {
    var workId: String
    var stichosIndex: Int
    var catalog: String
    var retrograde: String
    var placed: [String]
    var tray: [BenchTile]
    var misses: Int
}

/// Role: Furrow. A solved or abandoned bench sitting.
struct BenchAttempt: Codable, Equatable, Identifiable, Sendable {
    var id: String
    var workId: String
    var word: String
    var seq: Int
    var daykey: Int
    var solved: Bool
    var misses: Int
}

/// Role: Furrow. One word the reader has faced or yawed, kept in the book.
struct Lexeme: Codable, Equatable, Identifiable, Sendable {
    var id: String
    var catalog: String
    var retrograde: String
    var faceCount: Int
    var yawCount: Int
    var pinned: Bool
    var workIds: [String]
}

/// Role: Furrow. A named wall of paintings on this device.
struct Hang: Codable, Equatable, Identifiable, Sendable {
    var id: String
    var title: String
    var note: String
    var workIds: [String]
    var daykey: Int
}

/// Role: Furrow. One stop on today's visit route.
struct VisitStop: Codable, Equatable, Identifiable, Sendable {
    var id: String
    var workId: String
    var done: Bool
}

/// Role: Furrow. A caption the reader wrote for one painting.
struct CaptionDraft: Codable, Equatable, Identifiable, Sendable {
    var id: String
    var workId: String
    var title: String
    var body: String
    var daykey: Int
}

/// Role: Furrow. A private line for one day key.
struct DayNote: Codable, Equatable, Identifiable, Sendable {
    var id: String
    var daykey: Int
    var body: String
}

/// Role: Furrow. One day of practice, for the ledger.
struct DayTally: Equatable, Identifiable, Sendable {
    var daykey: Int
    var faces: Int
    var yaws: Int
    var ploughs: Int
    var benches: Int

    var id: Int { daykey }

    var isQuiet: Bool {
        faces + yaws + ploughs + benches == 0
    }
}

/// Role: Furrow. Lay tokens in ox-plough rows. Even rows run out. Odd rows run back.
enum PloughLayout {
    static let rowWidth = 4

    static func course(workId: String, field: FurrowField, line: String) -> PloughCourse? {
        let words = Stichos.tokens(in: line)
        guard words.count >= 2 else { return nil }
        let cells = words.enumerated().map { index, word in
            let row = index / rowWidth
            let column = index % rowWidth
            let countInRow = min(rowWidth, words.count - row * rowWidth)
            let visual = row % 2 == 0 ? column : (countInRow - 1 - column)
            return PloughCell(
                id: "\(workId).plough.\(index)",
                tokenIndex: index,
                word: word,
                row: row,
                visualSlot: visual
            )
        }
        return PloughCourse(
            workId: workId,
            field: field,
            cells: cells,
            nextToken: 0,
            misses: 0,
            rowWidth: rowWidth
        )
    }
}

/// Role: Furrow. One try at writing a caption from memory.
struct CoverAttempt: Codable, Equatable, Identifiable, Sendable {
    var id: String
    var workId: String
    var field: FurrowField
    var typed: String
    var hits: Int
    var misses: Int
    var daykey: Int
    var seq: Int
}

/// Role: Furrow. What a cover got right, what it dropped, and what it invented.
struct CoverReport: Equatable, Sendable {
    var hits: [String]
    var missing: [String]
    var extras: [String]

    var full: Bool { missing.isEmpty && extras.isEmpty && hits.isEmpty == false }
}

/// Role: Furrow. Grade a typed line against the catalog line. Order does not matter.
enum CoverCheck {
    static func grade(typed: String, line: String) -> CoverReport? {
        let expected = Stichos.tokens(in: line)
        guard expected.count >= 2 else { return nil }
        var pool = Stichos.tokens(in: typed)
        var hits: [String] = []
        var missing: [String] = []
        for word in expected {
            if let index = pool.firstIndex(where: { $0.compare(word, options: [.caseInsensitive, .diacriticInsensitive]) == .orderedSame }) {
                hits.append(word)
                pool.remove(at: index)
            } else {
                missing.append(word)
            }
        }
        return CoverReport(hits: hits, missing: missing, extras: pool)
    }
}

/// Role: Furrow. A room the reader has walked, with a note and minutes.
struct RoomMark: Codable, Equatable, Identifiable, Sendable {
    var id: String
    var title: String
    var note: String
    var walked: Bool
    var minutes: Int
}

/// Role: Furrow. A written comparison of two paintings.
/// Role: Furrow. What the reader noticed. Their words, not the gallery label.
/// Role: Furrow. A word the reader owes. A miss comes back tomorrow. A clean face waits longer.
struct MemoryCard: Codable, Equatable, Identifiable, Sendable {
    var id: String
    var workId: String
    var word: String
    var box: Int
    var due: Int
}

struct Notice: Codable, Equatable, Identifiable, Sendable {
    var id: String
    var light: String
    var thing: String
    var word: String
}

struct PairNote: Codable, Equatable, Identifiable, Sendable {
    var id: String
    var leftId: String
    var rightId: String
    var body: String
    var daykey: Int
}

/// Role: Furrow. One room as the crate currently holds it.
struct RoomRow: Equatable, Identifiable, Sendable {
    var id: String
    var title: String
    var workIds: [String]
    var note: String
    var walked: Bool
    var minutes: Int
}
