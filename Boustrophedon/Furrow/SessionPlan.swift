import Foundation

/// Role: Furrow. One job inside today's five. The fold on the painting stays Idle, Turned, or Faced.
enum SessionKind: String, Codable, Equatable, Sendable {
    case face
    case plough
    case bench
    case route
    case recall

    var title: String {
        switch self {
        case .face: "Face"
        case .plough: "Plough"
        case .bench: "Bench"
        case .route: "Route"
        case .recall: "Recall"
        }
    }
}

/// Role: Furrow. A stop that must be finished before today is filed.
struct SessionStop: Codable, Equatable, Identifiable, Sendable {
    var id: String
    var kind: SessionKind
    var workId: String
    var field: FurrowField
    var word: String
    var done: Bool
    var openedSeq: Int
}

/// Role: Furrow. The five stops for one day key. Tomorrow cuts a new five.
struct DaySession: Codable, Equatable, Sendable {
    var daykey: Int
    var stops: [SessionStop]
    var cursor: Int

    var filed: Bool {
        stops.isEmpty == false && stops.allSatisfy(\.done)
    }
}

/// Role: Furrow. Cuts today's five from misses, the crate, and the route.
enum SessionPlan {
    static func make(
        daykey: Int,
        works: [Work],
        lexemes: [Lexeme],
        route: [VisitStop],
        markSeq: Int,
        cards: [MemoryCard] = []
    ) -> DaySession? {
        let playable = works.filter(\.hasPlayableLine)
        guard let first = playable.first else { return nil }
        let second = playable.dropFirst().first ?? first
        let third = playable.count > 2 ? playable[2] : first

        let review = lexemes
            .filter { $0.yawCount > 0 }
            .sorted { $0.yawCount > $1.yawCount }
            .first
        let owed = cards.filter { $0.due <= daykey }.sorted { $0.due < $1.due }.first
        let owedWork = owed.flatMap { card in playable.first { $0.id == card.workId } }
        let reviewWork = owedWork ?? work(for: review, in: playable) ?? first
        let reviewWord = owed?.word ?? review?.catalog ?? oddWord(in: reviewWork, field: readyField(reviewWork))
        var stops: [SessionStop] = [
            stop("bench", .bench, reviewWork, reviewWord, daykey, markSeq),
            stop("plough", .plough, second, "", daykey, markSeq),
            stop("face", .face, third, "", daykey, markSeq)
        ]

        if let visit = route.first(where: { $0.done == false }),
           let routed = playable.first(where: { $0.id == visit.workId }) ?? works.first(where: { $0.id == visit.workId && $0.hasPlayableLine }) {
            stops.append(stop("route", .route, routed, "", daykey, markSeq))
        } else {
            stops.append(stop("route", .route, second, "", daykey, markSeq))
        }

        let pinned = lexemes.first(where: \.pinned)
        let recallWork = work(for: pinned, in: playable) ?? second
        let recallWord = pinned?.catalog ?? oddWord(in: recallWork, field: readyField(recallWork))
        stops.append(stop("recall", .recall, recallWork, recallWord, daykey, markSeq))

        return DaySession(daykey: daykey, stops: stops, cursor: 0)
    }

    static func readyField(_ work: Work) -> FurrowField {
        if let chosen = work.chosenField() { return chosen }
        if work.lineReady(.curatorial) { return .curatorial }
        if work.lineReady(.studio) { return .studio }
        return .title
    }

    static func field(containing word: String, in work: Work) -> FurrowField? {
        let needle = word.trimmingCharacters(in: .whitespacesAndNewlines)
        guard needle.isEmpty == false else { return nil }
        for field in [FurrowField.artist, .title, .curatorial, .studio] where work.lineReady(field) {
            let hit = Stichos.tokens(in: work.line(for: field)).contains {
                $0.compare(needle, options: [.caseInsensitive, .diacriticInsensitive]) == .orderedSame
            }
            if hit { return field }
        }
        return nil
    }

    private static func work(for lexeme: Lexeme?, in works: [Work]) -> Work? {
        guard let lexeme else { return nil }
        return works.first { lexeme.workIds.contains($0.id) } ?? works.first
    }

    private static func oddWord(in work: Work, field: FurrowField) -> String {
        let tokens = Stichos.tokens(in: work.line(for: field))
        if tokens.count > 1 { return tokens[1] }
        return tokens.first ?? ""
    }

    private static func stop(
        _ slug: String,
        _ kind: SessionKind,
        _ work: Work,
        _ word: String,
        _ daykey: Int,
        _ markSeq: Int
    ) -> SessionStop {
        let field = field(containing: word, in: work) ?? readyField(work)
        return SessionStop(
            id: "today.\(daykey).\(slug)",
            kind: kind,
            workId: work.id,
            field: field,
            word: word,
            done: false,
            openedSeq: markSeq
        )
    }
}
