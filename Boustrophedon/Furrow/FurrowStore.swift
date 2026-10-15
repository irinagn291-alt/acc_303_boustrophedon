import Foundation
import Observation

/// Role: Furrow. One observable fold. Views call turnFurrow, faceStichos, yawStichos, retractNewestMark.
@MainActor
@Observable
final class FurrowStore {
    static let shared = FurrowStore()
    static let demoKey = "bph.demo.v1"
    static let starterKey = "bph.starter.v1"

    private(set) var document: FurrowDocument
    var sheet: FurrowSheet = .none
    var didSucceedFace = false

    private let vault: FurrowVault
    private var writeTask: Task<Void, Never>?
    private let seedOnLaunch: Bool

    var works: [Work] { document.works }
    var liveFurrow: Furrow? { document.liveFurrow }
    var liveWork: Work? {
        guard let id = document.liveWorkId else { return nil }
        return document.works.first { $0.id == id }
    }
    var fold: Boustrophedon {
        liveWork?.fold ?? .idle
    }
    var statusCaption: String {
        if document.levelActive { return "Level" }
        switch fold {
        case .idle: return "Idle"
        case .turned: return "Turned"
        case .faced: return "Faced"
        }
    }
    var facedWorks: [Work] { document.works.filter { $0.fold == .faced } }
    var turnableWorks: [Work] {
        document.works.filter { $0.fold != .faced && $0.chosenField() != nil }
    }
    var faceCount: Int { document.faceMarks.count }
    var yawCount: Int { document.yawMarks.count }
    var accuracyPercent: Int {
        let total = faceCount + yawCount
        guard total > 0 else { return 0 }
        return Int((Double(faceCount) / Double(total) * 100).rounded())
    }
    var practiceStreak: Int {
        let days = Set(
            document.faceMarks.map(\.daykey)
                + document.yawMarks.map(\.daykey)
                + document.ploughPasses.map(\.daykey)
                + document.benchAttempts.map(\.daykey)
        )
        return DayKey.streak(in: days)
    }
    var routeLeft: Int { document.route.filter { $0.done == false }.count }
    var currentStop: SessionStop? {
        guard let session = document.daySession, session.stops.indices.contains(session.cursor) else { return nil }
        return session.stops[session.cursor]
    }
    var sessionFiled: Bool {
        guard let session = document.daySession, session.daykey == DayKey.current() else { return false }
        return session.filed
    }
    var sessionCountLine: String {
        guard let session = document.daySession, session.stops.isEmpty == false else { return "" }
        let done = session.stops.filter(\.done).count
        let place = min(session.cursor + 1, session.stops.count)
        if session.filed { return "\(OxFigures.count(session.stops.count)) of \(OxFigures.count(session.stops.count))" }
        return "\(OxFigures.count(place)) of \(OxFigures.count(session.stops.count)), \(OxFigures.count(done)) filed"
    }
    var sessionPrompt: String {
        guard let stop = currentStop else { return "Five stops are cut for today." }
        if stop.done, sessionFiled { return "Today is filed." }
        switch stop.kind {
        case .bench:
            return stop.word.isEmpty ? "Spell the backward word." : "Spell \(stop.word). It was a miss."
        case .plough:
            return "Walk this caption with the ox."
        case .face:
            return "Face each backward word."
        case .route:
            return "This painting is the next stop."
        case .recall:
            return stop.word.isEmpty ? "Spell a word from the book." : "Spell \(stop.word) from the book."
        }
    }
    var nextStopTitle: String {
        guard let stop = document.route.first(where: { $0.done == false }),
              let work = document.works.first(where: { $0.id == stop.workId }) else {
            return "The route is clear."
        }
        return work.title
    }
    var routeStationIndex: Int? {
        document.daySession?.stops.firstIndex { $0.kind == .route }
    }
    var roomRows: [RoomRow] {
        let named = document.works.filter { $0.roomLabel.isEmpty == false }
        let titles = Set(named.map(\.roomLabel)).sorted()
        return titles.map { title in
            let mark = document.roomMarks.first { $0.title == title }
            return RoomRow(
                id: title,
                title: title,
                workIds: named.filter { $0.roomLabel == title }.map(\.id),
                note: mark?.note ?? "",
                walked: mark?.walked ?? false,
                minutes: mark?.minutes ?? 0
            )
        }
    }
    var roomsWalked: Int { roomRows.filter(\.walked).count }
    var liveRoomTitle: String {
        let title = liveWork?.roomLabel ?? ""
        return title.isEmpty ? "No room yet." : title
    }
    var dayTallies: [DayTally] {
        var map: [Int: DayTally] = [:]
        func take(_ day: Int) -> DayTally {
            map[day] ?? DayTally(daykey: day, faces: 0, yaws: 0, ploughs: 0, benches: 0)
        }
        for mark in document.faceMarks {
            var row = take(mark.daykey)
            row.faces += 1
            map[mark.daykey] = row
        }
        for mark in document.yawMarks {
            var row = take(mark.daykey)
            row.yaws += 1
            map[mark.daykey] = row
        }
        for pass in document.ploughPasses {
            var row = take(pass.daykey)
            row.ploughs += 1
            map[pass.daykey] = row
        }
        for attempt in document.benchAttempts {
            var row = take(attempt.daykey)
            row.benches += 1
            map[attempt.daykey] = row
        }
        return map.values.sorted { $0.daykey > $1.daykey }
    }
    var canRetract: Bool {
        let floor = document.livePassFloor
        return document.faceMarks.contains { $0.seq > floor } || document.yawMarks.contains { $0.seq > floor }
    }

    init(
        suiteName: String? = nil,
        folder: URL? = nil,
        seedOnLaunch: Bool = true
    ) {
        let support = folder ?? FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
            .appendingPathComponent("Boustrophedon", isDirectory: true)
        let vault = FurrowVault(suiteName: suiteName, folder: support)
        self.vault = vault
        self.seedOnLaunch = seedOnLaunch
        var initial = vault.peek()
        if seedOnLaunch {
            initial = Self.applyLaunchSeed(initial, defaults: .standard)
        }
        self.document = initial
        publishLevel()
        if seedOnLaunch { prepareToday() }
        Task { await self.boot() }
    }

    init(preview document: FurrowDocument, suiteName: String, folder: URL) {
        self.vault = FurrowVault(suiteName: suiteName, folder: folder)
        self.seedOnLaunch = false
        self.document = document
    }

    func boot() async {
        let loaded = await vault.load()
        if seedOnLaunch {
            let seeded = Self.applyLaunchSeed(loaded, defaults: .standard)
            if seeded.works.isEmpty && document.works.isEmpty == false {
                publishLevel()
                persistSoon(immediate: true)
                return
            }
            document = seeded
        } else {
            document = loaded
        }
        publishLevel()
        if seedOnLaunch { prepareToday() }
        persistSoon(immediate: true)
    }

    func flush() {
        persistSoon(immediate: true)
    }

    func turnFurrow() {
        if liveWork?.fold == .turned { return }
        document.levelActive = false
        let pool = document.works.filter { $0.fold != .faced }
        guard let picked = pool.first(where: { fieldForTurn($0) != nil }),
              let field = fieldForTurn(picked),
              let furrow = Furrow.oxTurn(workId: picked.id, field: field, line: picked.line(for: field))
        else {
            document.levelActive = true
            document.liveFurrow = nil
            document.liveWorkId = nil
            persistSoon(immediate: true)
            return
        }
        commitLine(workId: picked.id, furrow: furrow)
    }

    @discardableResult
    func setLineScope(_ field: FurrowField) -> Bool {
        if let work = liveWork {
            guard work.lineReady(field),
                  let furrow = Furrow.oxTurn(workId: work.id, field: field, line: work.line(for: field))
            else { return false }
            document.lineScope = field
            commitLine(workId: work.id, furrow: furrow)
            return true
        }
        document.lineScope = field
        persistSoon(immediate: true)
        return true
    }

    func setDrillBlind(_ blind: Bool) {
        document.drillBlind = blind
        persistSoon(immediate: true)
    }

    @discardableResult
    func reopenForPractice(id: String, field: FurrowField) -> Bool {
        guard let work = document.works.first(where: { $0.id == id }),
              work.lineReady(field),
              let furrow = Furrow.oxTurn(workId: work.id, field: field, line: work.line(for: field))
        else { return false }
        if let previous = document.liveWorkId, previous != id {
            mutateWork(id: previous) { if $0.fold == .turned { $0.fold = .idle } }
        }
        document.lineScope = field
        document.levelActive = false
        commitLine(workId: id, furrow: furrow)
        return true
    }

    func updateNote(id: String, note: String) {
        mutateWork(id: id) { $0.userNote = note }
        if let index = document.cachedWorks.firstIndex(where: { $0.id == id }) {
            document.cachedWorks[index].userNote = note
        }
        persistSoon(immediate: false)
    }

    @discardableResult
    func addCustomEntry(title: String, maker: String, era: String, caption: String) -> Bool {
        let cleanTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        let cleanMaker = maker.trimmingCharacters(in: .whitespacesAndNewlines)
        let cleanEra = era.trimmingCharacters(in: .whitespacesAndNewlines)
        let cleanCaption = caption.trimmingCharacters(in: .whitespacesAndNewlines)
        let id = "local.\(UUID().uuidString)"
        let row = Work(
            id: id,
            identity: "Local",
            maker: cleanMaker,
            title: cleanTitle.isEmpty ? "Untitled" : cleanTitle,
            imageFile: "",
            daykey: DayKey.current(),
            fold: .idle,
            eraLabel: cleanEra,
            curatorialLine: cleanCaption
        )
        guard row.hasPlayableLine else { return false }
        document.works.append(row)
        if document.cachedWorks.contains(where: { $0.id == row.id }) == false {
            document.cachedWorks.append(row)
        }
        document.focusedWorkId = row.id
        if liveWork?.fold != .turned,
           let field = fieldForTurn(row),
           let furrow = Furrow.oxTurn(workId: row.id, field: field, line: row.line(for: field)) {
            commitLine(workId: row.id, furrow: furrow)
        } else {
            publishLevel()
            persistSoon(immediate: true)
        }
        return true
    }

    func saveWorks(_ incoming: [Work]) {
        for row in incoming {
            saveWork(row)
        }
    }

    func faceStichos(_ index: Int) -> Bool {
        guard liveWork?.fold != .idle, liveWork?.fold != nil else { return false }
        guard liveWork?.fold == .turned else { return false }
        guard var furrow = document.liveFurrow, furrow.stichoi.indices.contains(index) else { return false }
        let stichos = furrow.stichoi[index]
        if stichos.isRetrograde {
            document.markSeq += 1
            document.faceMarks.append(
                FaceMark(
                    id: "face.\(document.markSeq)",
                    workId: furrow.workId,
                    stichosIndex: index,
                    seq: document.markSeq,
                    daykey: DayKey.current()
                )
            )
            furrow = furrow.rights(index: index)
            recordLexeme(catalog: stichos.catalog, workId: furrow.workId, faced: true, delta: 1)
            document.liveFurrow = furrow
            if furrow.remainingRetrograde == 0 {
                mutateWork(id: furrow.workId) { $0.fold = .faced }
                if turnableWorks.isEmpty {
                    document.levelActive = true
                }
            }
            persistSoon(immediate: true)
            closeStationIfReady()
            return true
        }
        yawStichos(index)
        return false
    }

    func yawStichos(_ index: Int) {
        guard liveWork?.fold == .turned else { return }
        guard var furrow = document.liveFurrow, furrow.stichoi.indices.contains(index) else { return }
        let stichos = furrow.stichoi[index]
        document.markSeq += 1
        document.yawMarks.append(
            YawMark(
                id: "yaw.\(document.markSeq)",
                workId: furrow.workId,
                stichosIndex: index,
                seq: document.markSeq,
                daykey: DayKey.current()
            )
        )
        recordLexeme(catalog: stichos.catalog, workId: furrow.workId, faced: false, delta: 1)
        furrow = furrow.cools(index: index)
        document.liveFurrow = furrow
        persistSoon(immediate: true)
    }

    func retractNewestMark() {
        let floor = document.livePassFloor
        let lastFace = document.faceMarks.filter { $0.seq > floor }.max(by: { $0.seq < $1.seq })
        let lastYaw = document.yawMarks.filter { $0.seq > floor }.max(by: { $0.seq < $1.seq })
        if let face = lastFace, lastYaw == nil || face.seq > (lastYaw?.seq ?? 0) {
            if let word = wordForMark(workId: face.workId, index: face.stichosIndex) {
                recordLexeme(catalog: word, workId: face.workId, faced: true, delta: -1)
            }
            document.faceMarks.removeAll { $0.id == face.id }
            if let furrow = document.liveFurrow, furrow.workId == face.workId {
                document.liveFurrow = furrow.unrights(index: face.stichosIndex)
            } else if let work = document.works.first(where: { $0.id == face.workId }),
                      let field = work.chosenField(),
                      var furrow = Furrow.oxTurn(workId: work.id, field: field, line: work.line(for: field)) {
                for mark in document.faceMarks where mark.workId == work.id {
                    furrow = furrow.rights(index: mark.stichosIndex)
                }
                for mark in document.yawMarks where mark.workId == work.id {
                    furrow = furrow.cools(index: mark.stichosIndex)
                }
                furrow = furrow.unrights(index: face.stichosIndex)
                document.liveFurrow = furrow
                document.liveWorkId = work.id
            }
            mutateWork(id: face.workId) { work in
                if work.fold == .faced { work.fold = .turned }
            }
            document.levelActive = false
        } else if let yaw = lastYaw {
            if let word = wordForMark(workId: yaw.workId, index: yaw.stichosIndex) {
                recordLexeme(catalog: word, workId: yaw.workId, faced: false, delta: -1)
            }
            document.yawMarks.removeAll { $0.id == yaw.id }
            if let furrow = document.liveFurrow, furrow.workId == yaw.workId {
                document.liveFurrow = furrow.reheats(index: yaw.stichosIndex)
            }
        }
        persistSoon(immediate: true)
    }

    func saveWork(_ incoming: Work) {
        if let existing = document.works.first(where: { $0.id == incoming.id }) {
            document.focusedWorkId = existing.id
            persistSoon(immediate: true)
            return
        }
        var row = incoming
        row.fold = .idle
        row.daykey = DayKey.current()
        document.works.append(row)
        document.focusedWorkId = row.id
        if document.cachedWorks.contains(where: { $0.id == row.id }) == false {
            document.cachedWorks.append(row)
        }
        publishLevel()
        if liveWork?.fold != .turned {
            turnFurrow()
        }
        persistSoon(immediate: true)
    }

    func rememberCache(_ rows: [Work]) {
        for row in rows where document.cachedWorks.contains(where: { $0.id == row.id }) == false {
            document.cachedWorks.append(row)
        }
        persistSoon(immediate: false)
    }

    func completeOnboarding() {
        document.onboardingComplete = true
        persistSoon(immediate: true)
    }

    func rerunOnboarding() {
        document.onboardingComplete = false
        persistSoon(immediate: true)
    }

    func resetAllData() {
        document = .empty()
        publishLevel()
        persistSoon(immediate: true)
        Task { await vault.wipe() }
    }

    func setStudioTool(_ tool: StudioTool) {
        document.studioTool = tool
        switch tool {
        case .face:
            break
        case .plough:
            _ = openPlough()
        case .bench:
            _ = openBench()
        case .cover:
            break
        }
        persistSoon(immediate: true)
    }

    @discardableResult
    func openPlough() -> Bool {
        guard let work = liveWork else { return false }
        let field = document.liveFurrow?.field ?? fieldForTurn(work)
        guard let field else { return false }
        if let live = document.livePlough, live.workId == work.id, live.field == field {
            return true
        }
        guard let course = PloughLayout.course(workId: work.id, field: field, line: work.line(for: field)) else {
            document.livePlough = nil
            persistSoon(immediate: true)
            return false
        }
        document.livePlough = course
        persistSoon(immediate: true)
        return true
    }

    @discardableResult
    func restartPlough() -> Bool {
        document.livePlough = nil
        return openPlough()
    }

    @discardableResult
    func tapPlough(tokenIndex: Int) -> Bool {
        guard var course = document.livePlough else { return false }
        guard course.cells.contains(where: { $0.tokenIndex == tokenIndex }) else { return false }
        guard tokenIndex >= course.nextToken else { return false }
        if tokenIndex != course.nextToken {
            course.misses += 1
            document.livePlough = course
            persistSoon(immediate: true)
            return false
        }
        course.nextToken += 1
        if course.nextToken >= course.cells.count {
            document.markSeq += 1
            document.ploughPasses.append(
                PloughPass(
                    id: "plough.\(document.markSeq)",
                    workId: course.workId,
                    field: course.field,
                    seq: document.markSeq,
                    daykey: DayKey.current(),
                    steps: course.cells.count,
                    misses: course.misses,
                    finished: true
                )
            )
            document.livePlough = nil
            persistSoon(immediate: true)
            closeStationIfReady()
            return true
        }
        document.livePlough = course
        persistSoon(immediate: true)
        return true
    }

    @discardableResult
    func openBench(word: String? = nil) -> Bool {
        let asked = word?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        if asked.isEmpty == false {
            return openBench(catalog: asked)
        }
        guard let furrow = document.liveFurrow,
              let stichos = furrow.stichoi.first(where: \.isRetrograde) else {
            document.liveBench = nil
            persistSoon(immediate: true)
            return false
        }
        return openBench(catalog: stichos.catalog, stichos: stichos, workId: furrow.workId)
    }

    private func openBench(catalog: String, stichos: Stichos? = nil, workId: String? = nil) -> Bool {
        let clean = catalog.trimmingCharacters(in: .whitespacesAndNewlines)
        guard clean.isEmpty == false else { return false }
        let owner = workId ?? liveWork?.id ?? ""
        let index = stichos?.index ?? -1
        if let live = document.liveBench,
           live.workId == owner,
           live.catalog == clean,
           live.stichosIndex == index {
            return true
        }
        let letters = Array(clean).map(String.init)
        guard letters.isEmpty == false else { return false }
        let tiles = letters.enumerated().map { offset, letter in
            BenchTile(id: "bench.\(owner).\(offset).\(UUID().uuidString)", letter: letter)
        }.shuffled()
        let shown: String
        if stichos?.isRetrograde == true, let retrograde = stichos?.shown {
            shown = retrograde
        } else {
            shown = Stichos.letterReverse(clean)
        }
        document.liveBench = BenchCourse(
            workId: owner,
            stichosIndex: index,
            catalog: clean,
            retrograde: shown,
            placed: [],
            tray: tiles,
            misses: 0
        )
        persistSoon(immediate: true)
        return true
    }

    func prepareToday() {
        let today = DayKey.current()
        if document.memoryCards.isEmpty, document.works.count >= 2 {
            let first = document.works[0]
            let second = document.works[1]
            let wordA = Stichos.tokens(in: first.line(for: SessionPlan.readyField(first))).dropFirst().first
                ?? Stichos.tokens(in: first.title).first
                ?? "line"
            let wordB = Stichos.tokens(in: second.line(for: SessionPlan.readyField(second))).dropFirst().first
                ?? "title"
            document.memoryCards = [
                MemoryCard(id: "\(first.id)|\(wordA.lowercased())", workId: first.id, word: String(wordA), box: 1, due: today),
                MemoryCard(id: "\(second.id)|\(wordB.lowercased())", workId: second.id, word: String(wordB), box: 1, due: today)
            ]
        }
        let session = document.daySession
        let stale = session == nil || session?.daykey != today || session?.stops.isEmpty == true
        if stale {
            document.daySession = SessionPlan.make(
                daykey: today,
                works: document.works,
                lexemes: document.lexemes,
                route: document.route,
                markSeq: document.markSeq,
                cards: document.memoryCards
            )
            persistSoon(immediate: true)
            if let cursor = document.daySession?.cursor {
                openStation(cursor)
            }
            return
        }
        if liveFurrow == nil,
           let session,
           session.stops.indices.contains(session.cursor),
           session.stops[session.cursor].done == false {
            openStation(session.cursor)
        }
    }

    func replayToday() {
        document.daySession = nil
        prepareToday()
    }

    func openStation(_ index: Int) {
        guard var session = document.daySession, session.stops.indices.contains(index) else { return }
        session.cursor = index
        document.daySession = session
        let stop = session.stops[index]
        let field = stop.field
        guard reopenForPractice(id: stop.workId, field: field) || liveWork?.id == stop.workId else { return }
        switch stop.kind {
        case .face, .route:
            document.studioTool = .face
        case .plough:
            document.studioTool = .plough
            _ = openPlough()
        case .bench, .recall:
            document.studioTool = .bench
            _ = openBench(word: stop.word)
        }
        persistSoon(immediate: true)
    }

    private func closeStationIfReady() {
        guard var session = document.daySession, session.stops.indices.contains(session.cursor) else { return }
        var stop = session.stops[session.cursor]
        guard stop.done == false else { return }
        guard stationMet(stop, daykey: session.daykey) else { return }
        stop.done = true
        if stop.kind == .route,
           let routeIndex = document.route.firstIndex(where: { $0.workId == stop.workId && $0.done == false }) {
            document.route[routeIndex].done = true
        }
        session.stops[session.cursor] = stop
        if let next = session.stops.indices.first(where: { session.stops[$0].done == false }) {
            session.cursor = next
            document.daySession = session
            persistSoon(immediate: true)
            openStation(next)
        } else {
            document.daySession = session
            persistSoon(immediate: true)
        }
    }

    private func stationMet(_ stop: SessionStop, daykey: Int) -> Bool {
        switch stop.kind {
        case .face, .route:
            let fresh = document.faceMarks.contains { $0.workId == stop.workId && $0.seq > stop.openedSeq && $0.daykey == daykey }
            let onThisLine = document.liveFurrow?.workId == stop.workId && document.liveFurrow?.remainingRetrograde == 0
            let filed = document.works.first { $0.id == stop.workId }?.fold == .faced
            return fresh && (onThisLine || filed)
        case .plough:
            return document.ploughPasses.contains { $0.workId == stop.workId && $0.seq > stop.openedSeq && $0.daykey == daykey && $0.finished }
        case .bench, .recall:
            let needle = stop.word.lowercased()
            return document.benchAttempts.contains {
                $0.solved && $0.seq > stop.openedSeq && $0.daykey == daykey && $0.word.lowercased() == needle
            }
        }
    }

    @discardableResult
    func placeBench(tileId: String) -> Bool {
        guard var course = document.liveBench,
              let tile = course.tray.first(where: { $0.id == tileId }) else { return false }
        let expected = Array(course.catalog).map(String.init)
        let slot = course.placed.count
        guard expected.indices.contains(slot) else { return false }
        guard expected[slot] == tile.letter else {
            course.misses += 1
            document.liveBench = course
            persistSoon(immediate: true)
            return false
        }
        course.tray.removeAll { $0.id == tileId }
        course.placed.append(tile.letter)
        if course.placed.count == expected.count {
            document.markSeq += 1
            document.benchAttempts.append(
                BenchAttempt(
                    id: "bench.\(document.markSeq)",
                    workId: course.workId,
                    word: course.catalog,
                    seq: document.markSeq,
                    daykey: DayKey.current(),
                    solved: true,
                    misses: course.misses
                )
            )
            let index = course.stichosIndex
            document.liveBench = nil
            persistSoon(immediate: true)
            let faced = document.liveFurrow?.stichoi.indices.contains(index) == true
                && document.liveFurrow?.stichoi[index].isRetrograde == true
                && faceStichos(index)
            if faced == false {
                closeStationIfReady()
            }
            return true
        }
        document.liveBench = course
        persistSoon(immediate: true)
        return true
    }

    func undoBench() {
        guard var course = document.liveBench, let last = course.placed.popLast() else { return }
        course.tray.append(BenchTile(id: "undo.\(UUID().uuidString)", letter: last))
        document.liveBench = course
        persistSoon(immediate: true)
    }

    @discardableResult
    func createHang(title: String) -> String? {
        let clean = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard clean.isEmpty == false else { return nil }
        let id = "hang.\(UUID().uuidString)"
        document.hangs.insert(
            Hang(id: id, title: clean, note: "", workIds: [], daykey: DayKey.current()),
            at: 0
        )
        persistSoon(immediate: true)
        return id
    }

    func renameHang(id: String, title: String) {
        let clean = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard clean.isEmpty == false else { return }
        guard let index = document.hangs.firstIndex(where: { $0.id == id }) else { return }
        document.hangs[index].title = clean
        persistSoon(immediate: true)
    }

    func updateHangNote(id: String, note: String) {
        guard let index = document.hangs.firstIndex(where: { $0.id == id }) else { return }
        document.hangs[index].note = note
        persistSoon(immediate: false)
    }

    func deleteHang(id: String) {
        document.hangs.removeAll { $0.id == id }
        persistSoon(immediate: true)
    }

    func addWork(_ workId: String, toHang hangId: String) {
        guard document.works.contains(where: { $0.id == workId }),
              let index = document.hangs.firstIndex(where: { $0.id == hangId }) else { return }
        if document.hangs[index].workIds.contains(workId) { return }
        document.hangs[index].workIds.append(workId)
        persistSoon(immediate: true)
    }

    func removeWork(_ workId: String, fromHang hangId: String) {
        guard let index = document.hangs.firstIndex(where: { $0.id == hangId }) else { return }
        document.hangs[index].workIds.removeAll { $0 == workId }
        persistSoon(immediate: true)
    }

    func moveHangWork(hangId: String, workId: String, direction: Int) {
        guard let hangIndex = document.hangs.firstIndex(where: { $0.id == hangId }),
              let index = document.hangs[hangIndex].workIds.firstIndex(of: workId) else { return }
        let target = index + direction
        guard document.hangs[hangIndex].workIds.indices.contains(target) else { return }
        document.hangs[hangIndex].workIds.swapAt(index, target)
        persistSoon(immediate: true)
    }

    @discardableResult
    func fileOntoHang(workId: String) -> String? {
        guard document.works.contains(where: { $0.id == workId }) else { return nil }
        let hangId = document.hangs.first?.id ?? createHang(title: "My hang")
        guard let hangId else { return nil }
        addWork(workId, toHang: hangId)
        return hangId
    }

    @discardableResult
    func addToRoute(workId: String) -> Bool {
        guard document.works.contains(where: { $0.id == workId }) else { return false }
        if document.route.contains(where: { $0.workId == workId }) { return false }
        document.route.append(VisitStop(id: "stop.\(UUID().uuidString)", workId: workId, done: false))
        persistSoon(immediate: true)
        return true
    }

    func toggleStop(id: String) {
        guard let index = document.route.firstIndex(where: { $0.id == id }) else { return }
        document.route[index].done.toggle()
        persistSoon(immediate: true)
    }

    func clearFinishedStops() {
        document.route.removeAll { $0.done }
        persistSoon(immediate: true)
    }

    func removeStop(id: String) {
        document.route.removeAll { $0.id == id }
        persistSoon(immediate: true)
    }

    func moveStop(id: String, direction: Int) {
        guard let index = document.route.firstIndex(where: { $0.id == id }) else { return }
        let target = index + direction
        guard document.route.indices.contains(target) else { return }
        document.route.swapAt(index, target)
        persistSoon(immediate: true)
    }

    func openStop(id: String) {
        guard let stop = document.route.first(where: { $0.id == id }),
              let work = document.works.first(where: { $0.id == stop.workId }) else { return }
        let field = work.chosenField() ?? (work.lineReady(.curatorial) ? FurrowField.curatorial : nil)
        guard let field else { return }
        if reopenForPractice(id: work.id, field: field) {
            document.studioTool = .face
            sheet = .none
        }
    }

    @discardableResult
    func saveDraft(workId: String, title: String, body: String) -> Bool {
        let cleanBody = body.trimmingCharacters(in: .whitespacesAndNewlines)
        guard document.works.contains(where: { $0.id == workId }),
              Stichos.tokens(in: cleanBody).count >= 2 else { return false }
        let cleanTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        document.drafts.insert(
            CaptionDraft(
                id: "draft.\(UUID().uuidString)",
                workId: workId,
                title: cleanTitle.isEmpty ? "Caption" : cleanTitle,
                body: cleanBody,
                daykey: DayKey.current()
            ),
            at: 0
        )
        persistSoon(immediate: true)
        return true
    }

    func deleteDraft(id: String) {
        document.drafts.removeAll { $0.id == id }
        persistSoon(immediate: true)
    }

    @discardableResult
    func turnDraft(id: String) -> Bool {
        guard let draft = document.drafts.first(where: { $0.id == id }) else { return false }
        mutateWork(id: draft.workId) { $0.studioLine = draft.body }
        guard reopenForPractice(id: draft.workId, field: .studio) else { return false }
        document.studioTool = .face
        return true
    }

    func updateDayNote(daykey: Int, body: String) {
        if let index = document.dayNotes.firstIndex(where: { $0.daykey == daykey }) {
            document.dayNotes[index].body = body
        } else {
            document.dayNotes.append(DayNote(id: "day.\(daykey)", daykey: daykey, body: body))
        }
        persistSoon(immediate: false)
    }

    func setLexemePinned(id: String, pinned: Bool) {
        guard let index = document.lexemes.firstIndex(where: { $0.id == id }) else { return }
        document.lexemes[index].pinned = pinned
        persistSoon(immediate: true)
    }

    func practiceLexeme(id: String) {
        guard let lexeme = document.lexemes.first(where: { $0.id == id }) else { return }
        for workId in lexeme.workIds {
            guard let work = document.works.first(where: { $0.id == workId }) else { continue }
            let field = work.chosenField() ?? (work.lineReady(.curatorial) ? FurrowField.curatorial : nil)
            guard let field, reopenForPractice(id: work.id, field: field) else { continue }
            document.studioTool = .face
            sheet = .none
            return
        }
    }

    func recentDayKeys(count: Int = 7) -> [Int] {
        var days = [DayKey.current()]
        while days.count < count {
            guard let last = days.last, let prior = DayKey.previous(last) else { break }
            days.append(prior)
        }
        return days.reversed()
    }

    @discardableResult
    func fileCover(typed: String) -> CoverReport? {
        guard let work = liveWork else { return nil }
        let field = document.liveFurrow?.field ?? SessionPlan.readyField(work)
        guard let report = CoverCheck.grade(typed: typed, line: work.line(for: field)) else { return nil }
        document.markSeq += 1
        document.coverAttempts.insert(
            CoverAttempt(
                id: "cover.\(document.markSeq)",
                workId: work.id,
                field: field,
                typed: typed.trimmingCharacters(in: .whitespacesAndNewlines),
                hits: report.hits.count,
                misses: report.missing.count,
                daykey: DayKey.current(),
                seq: document.markSeq
            ),
            at: 0
        )
        persistSoon(immediate: true)
        return report
    }

    func setRoomWalked(title: String, walked: Bool) {
        var mark = roomMark(title)
        mark.walked = walked
        if walked, mark.minutes == 0 { mark.minutes = 10 }
        storeRoom(mark)
    }

    func shiftRoomMinutes(title: String, delta: Int) {
        var mark = roomMark(title)
        mark.minutes = max(0, mark.minutes + delta)
        storeRoom(mark)
    }

    func updateRoomNote(title: String, note: String) {
        var mark = roomMark(title)
        mark.note = note
        storeRoom(mark)
    }

    @discardableResult
    func savePair(leftId: String, rightId: String, body: String) -> Bool {
        let clean = body.trimmingCharacters(in: .whitespacesAndNewlines)
        guard leftId != rightId,
              document.works.contains(where: { $0.id == leftId }),
              document.works.contains(where: { $0.id == rightId }),
              Stichos.tokens(in: clean).count >= 2 else { return false }
        document.pairNotes.insert(
            PairNote(
                id: "pair.\(UUID().uuidString)",
                leftId: leftId,
                rightId: rightId,
                body: clean,
                daykey: DayKey.current()
            ),
            at: 0
        )
        persistSoon(immediate: true)
        return true
    }

    func deletePair(id: String) {
        document.pairNotes.removeAll { $0.id == id }
        persistSoon(immediate: true)
    }

    @discardableResult
    func saveNotice(workId: String, light: String, thing: String, word: String) -> Bool {
        let cleanLight = light.trimmingCharacters(in: .whitespacesAndNewlines)
        let cleanThing = thing.trimmingCharacters(in: .whitespacesAndNewlines)
        let cleanWord = word.trimmingCharacters(in: .whitespacesAndNewlines)
        guard document.works.contains(where: { $0.id == workId }) else { return false }
        guard [cleanLight, cleanThing, cleanWord].contains(where: { Stichos.tokens(in: $0).count >= 2 }) else { return false }
        let note = Notice(id: workId, light: cleanLight, thing: cleanThing, word: cleanWord)
        if let index = document.notices.firstIndex(where: { $0.id == workId }) {
            document.notices[index] = note
        } else {
            document.notices.insert(note, at: 0)
        }
        persistSoon(immediate: true)
        return true
    }

    private func roomMark(_ title: String) -> RoomMark {
        if let existing = document.roomMarks.first(where: { $0.title == title }) {
            return existing
        }
        return RoomMark(id: title, title: title, note: "", walked: false, minutes: 0)
    }

    private func storeRoom(_ mark: RoomMark) {
        if let index = document.roomMarks.firstIndex(where: { $0.title == mark.title }) {
            document.roomMarks[index] = mark
        } else {
            document.roomMarks.append(mark)
        }
        persistSoon(immediate: true)
    }

    var dueTodayCount: Int {
        let today = DayKey.current()
        return document.memoryCards.filter { $0.due <= today }.count
    }

    var libraryCount: Int { GalleryShelf.works(daykey: DayKey.current()).count }

    var checkersMoves: [CheckersMove] {
        CheckersRules.legal(document.checkersMatch)
    }

    func playCheckers(from: Int, to: Int) {
        guard let move = checkersMoves.first(where: { $0.from == from && $0.to == to }) else { return }
        var match = CheckersRules.after(document.checkersMatch, move)
        noteCheckersWinner(before: document.checkersMatch, after: match)
        var hops = 0
        while match.turn == .house, match.winner == nil, hops < 16 {
            hops += 1
            guard let reply = CheckersRules.houseChoice(match) else {
                match.winner = .player
                break
            }
            let stepped = CheckersRules.after(match, reply)
            noteCheckersWinner(before: match, after: stepped)
            match = stepped
        }
        document.checkersMatch = match
        persistSoon(immediate: true)
    }

    func newCheckersGame() {
        document.checkersMatch = .opening()
        persistSoon(immediate: true)
    }

    private func noteCheckersWinner(before: CheckersMatch, after: CheckersMatch) {
        guard before.winner == nil else { return }
        if after.winner == .player { document.checkersWins += 1 }
        if after.winner == .house { document.checkersLosses += 1 }
    }

    func present(_ sheet: FurrowSheet) {
        self.sheet = sheet
    }

    func applyReview(_ key: ReviewScreenKey?) {
        switch key {
        case .today, .none:
            sheet = .none
        case .log:
            sheet = .saved
        case .goals:
            sheet = .settings
        case .explore:
            sheet = .explore
        }
    }

    private func fieldForTurn(_ work: Work) -> FurrowField? {
        if let scope = document.lineScope, work.lineReady(scope) {
            return scope
        }
        if let chosen = work.chosenField() {
            return chosen
        }
        if work.lineReady(.curatorial) {
            return .curatorial
        }
        return nil
    }

    private func commitLine(workId: String, furrow: Furrow) {
        document.levelActive = false
        document.liveFurrow = furrow
        document.liveWorkId = workId
        document.livePassFloor = document.markSeq
        document.livePlough = nil
        document.liveBench = nil
        mutateWork(id: workId) { $0.fold = .turned }
        persistSoon(immediate: true)
    }

    private func scheduleMemory(word: String, workId: String, missed: Bool) {
        let today = DayKey.current()
        let key = "\(workId)|\(word.lowercased())"
        let gaps = [1, 2, 4, 8, 16]
        let box: Int
        let due: Int
        if missed {
            box = 1
            due = DayKey.adding(1, to: today) ?? today
        } else {
            let current = document.memoryCards.first { $0.id == key }?.box ?? 0
            box = min(5, current + 1)
            due = DayKey.adding(gaps[box - 1], to: today) ?? today
        }
        let card = MemoryCard(id: key, workId: workId, word: word, box: box, due: due)
        if let index = document.memoryCards.firstIndex(where: { $0.id == key }) {
            document.memoryCards[index] = card
        } else {
            document.memoryCards.append(card)
        }
    }

    private func recordLexeme(catalog: String, workId: String, faced: Bool, delta: Int) {
        let trimmed = catalog.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmed.isEmpty == false else { return }
        if delta > 0 {
            scheduleMemory(word: trimmed, workId: workId, missed: faced == false)
        }
        let key = trimmed.lowercased()
        if let index = document.lexemes.firstIndex(where: { $0.id == key }) {
            if faced {
                document.lexemes[index].faceCount = max(0, document.lexemes[index].faceCount + delta)
            } else {
                document.lexemes[index].yawCount = max(0, document.lexemes[index].yawCount + delta)
            }
            if delta > 0, document.lexemes[index].workIds.contains(workId) == false {
                document.lexemes[index].workIds.append(workId)
            }
            return
        }
        guard delta > 0 else { return }
        document.lexemes.append(
            Lexeme(
                id: key,
                catalog: trimmed,
                retrograde: Stichos.letterReverse(trimmed),
                faceCount: faced ? delta : 0,
                yawCount: faced ? 0 : delta,
                pinned: false,
                workIds: [workId]
            )
        )
    }

    private func wordForMark(workId: String, index: Int) -> String? {
        if let furrow = document.liveFurrow,
           furrow.workId == workId,
           furrow.stichoi.indices.contains(index) {
            return furrow.stichoi[index].catalog
        }
        guard let work = document.works.first(where: { $0.id == workId }) else { return nil }
        let field = work.chosenField() ?? (work.lineReady(.curatorial) ? FurrowField.curatorial : nil)
        guard let field else { return nil }
        let tokens = Stichos.tokens(in: work.line(for: field))
        guard tokens.indices.contains(index) else { return nil }
        return tokens[index]
    }

    private func publishLevel() {
        if liveWork?.fold == .turned {
            document.levelActive = false
            return
        }
        guard turnableWorks.isEmpty else {
            if document.levelActive { document.levelActive = false }
            return
        }
        if document.levelActive && document.liveFurrow == nil && document.liveWorkId == nil {
            return
        }
        turnFurrow()
    }

    private func mutateWork(id: String, _ body: (inout Work) -> Void) {
        guard let idx = document.works.firstIndex(where: { $0.id == id }) else { return }
        body(&document.works[idx])
    }

    private func persistSoon(immediate: Bool) {
        writeTask?.cancel()
        let snapshot = document
        writeTask = Task { [vault] in
            if !immediate {
                try? await Task.sleep(for: .milliseconds(280))
                if Task.isCancelled { return }
            }
            await vault.save(snapshot)
        }
    }

    static func applyLaunchSeed(_ loaded: FurrowDocument, defaults: UserDefaults) -> FurrowDocument {
        #if targetEnvironment(simulator)
        return ensureStudio(applySimulatorSeed(loaded, defaults: defaults))
        #else
        if loaded.works.isEmpty == false {
            return ensureStudio(loaded)
        }
        if defaults.bool(forKey: starterKey) {
            return ensureStudio(loaded)
        }
        defaults.set(true, forKey: starterKey)
        return ensureStudio(starterCrate(loaded))
        #endif
    }

    /// An update that already has paintings grows a hang, a route, and a word once.
    /// The flag lives on the document, so a later disk read cannot skip the plant.
    static func ensureStudio(_ loaded: FurrowDocument) -> FurrowDocument {
        guard loaded.studioPlanted == false else { return loaded }
        guard loaded.hangs.isEmpty, loaded.works.count >= 3 else {
            var marked = loaded
            marked.studioPlanted = true
            return marked
        }
        var doc = loaded
        let tool = loaded.studioTool
        dressStudio(&doc, shelf: loaded.works, day: DayKey.current())
        doc.liveFurrow = loaded.liveFurrow
        doc.liveWorkId = loaded.liveWorkId
        doc.onboardingComplete = loaded.onboardingComplete
        doc.works = loaded.works
        doc.studioTool = tool
        doc.studioPlanted = true
        return doc
    }

    /// First launch on a device: a live line is waiting, and welcome still has to be finished.
    static func starterCrate(_ loaded: FurrowDocument) -> FurrowDocument {
        var doc = loaded
        let day = DayKey.current()
        var shelf = Array(GalleryShelf.works(daykey: day).prefix(6))
        guard shelf.count >= 6 else { return doc }
        shelf[0].fold = .turned
        shelf[1].fold = .idle
        shelf[2].fold = .faced
        shelf[3].fold = .idle
        shelf[4].fold = .idle
        shelf[5].fold = .faced
        doc.works = shelf
        doc.cachedWorks = []
        doc.faceMarks = [
            FaceMark(id: "starter.face.1", workId: shelf[2].id, stichosIndex: 1, seq: 1, daykey: day)
        ]
        doc.yawMarks = [
            YawMark(id: "starter.yaw.1", workId: shelf[0].id, stichosIndex: 0, seq: 2, daykey: day)
        ]
        if let field = shelf[0].chosenField(),
           var furrow = Furrow.oxTurn(workId: shelf[0].id, field: field, line: shelf[0].line(for: field)) {
            furrow = furrow.cools(index: 0)
            doc.liveFurrow = furrow
            doc.liveWorkId = shelf[0].id
        }
        doc.markSeq = 2
        doc.livePassFloor = 0
        doc.onboardingComplete = false
        doc.levelActive = false
        doc.drillBlind = false
        doc.lineScope = nil
        Self.dressStudio(&doc, shelf: shelf, day: day)
        return doc
    }

    static func applySimulatorSeed(_ loaded: FurrowDocument, defaults: UserDefaults) -> FurrowDocument {
        #if targetEnvironment(simulator)
        guard defaults.bool(forKey: demoKey) == false else { return loaded }
        defaults.set(true, forKey: demoKey)
        var doc = loaded
        let day = DayKey.current()
        var shelf = GalleryShelf.works(daykey: day)
        if shelf.count >= 5 {
            shelf[0].fold = .turned
            shelf[1].fold = .idle
            shelf[2].fold = .faced
            shelf[3].fold = .idle
            shelf[4].fold = .faced
        }
        doc.works = shelf
        doc.cachedWorks = shelf
        if shelf.count >= 5 {
            doc.faceMarks = [
                FaceMark(id: "seed.face.1", workId: shelf[2].id, stichosIndex: 1, seq: 1, daykey: day)
            ]
            doc.yawMarks = [
                YawMark(id: "seed.yaw.1", workId: shelf[0].id, stichosIndex: 0, seq: 2, daykey: day),
                YawMark(id: "seed.yaw.2", workId: shelf[3].id, stichosIndex: 0, seq: 3, daykey: day)
            ]
            if let field = shelf[0].chosenField(),
               var furrow = Furrow.oxTurn(workId: shelf[0].id, field: field, line: shelf[0].line(for: field)) {
                furrow = furrow.cools(index: 0)
                doc.liveFurrow = furrow
                doc.liveWorkId = shelf[0].id
            }
        }
        doc.markSeq = 3
        doc.onboardingComplete = true
        doc.levelActive = false
        Self.dressStudio(&doc, shelf: shelf, day: day)
        return doc
        #else
        return loaded
        #endif
    }

    /// First launch already has a wall, a route, a word, and a caption, so the studio is in use.
    static func dressStudio(_ doc: inout FurrowDocument, shelf: [Work], day: Int) {
        guard shelf.count >= 3 else { return }
        let hung = uniqueIDs([
            shelf[0].id,
            shelf[min(2, shelf.count - 1)].id,
            shelf[min(4, shelf.count - 1)].id
        ])
        doc.hangs = [
            Hang(
                id: "hang.north",
                title: "North wall",
                note: "Quiet portraits for a slow hour.",
                workIds: hung,
                daykey: day
            )
        ]
        doc.route = [
            VisitStop(id: "stop.1", workId: shelf[1].id, done: false),
            VisitStop(id: "stop.2", workId: shelf[min(3, shelf.count - 1)].id, done: true)
        ]
        doc.lexemes = sampleLexemes(from: shelf)
        doc.ploughPasses = [
            PloughPass(
                id: "plough.seed",
                workId: shelf[2].id,
                field: .title,
                seq: 4,
                daykey: day,
                steps: 3,
                misses: 1,
                finished: true
            )
        ]
        doc.benchAttempts = [
            BenchAttempt(
                id: "bench.seed",
                workId: shelf[0].id,
                word: "van",
                seq: 5,
                daykey: day,
                solved: true,
                misses: 0
            )
        ]
        doc.drafts = [
            CaptionDraft(
                id: "draft.seed",
                workId: shelf[0].id,
                title: "Mirror line",
                body: "A small dog waits in the quiet room",
                daykey: day
            )
        ]
        doc.dayNotes = [
            DayNote(id: "day.\(day)", daykey: day, body: "Faced the couple first.")
        ]
        let room = shelf[0].roomLabel
        if room.isEmpty == false {
            doc.roomMarks = [
                RoomMark(id: room, title: room, note: "Start here. The light is quiet.", walked: true, minutes: 12)
            ]
        }
        if shelf.count > 1 {
            doc.pairNotes = [
                PairNote(
                    id: "pair.seed",
                    leftId: shelf[0].id,
                    rightId: shelf[1].id,
                    body: "Both keep a still figure against a wide ground.",
                    daykey: day
                )
            ]
            let tokens = Stichos.tokens(in: shelf[0].title)
            doc.coverAttempts = [
                CoverAttempt(
                    id: "cover.seed",
                    workId: shelf[0].id,
                    field: .title,
                    typed: shelf[0].title,
                    hits: tokens.count,
                    misses: 0,
                    daykey: day,
                    seq: 6
                )
            ]
        }
        doc.notices = [
            Notice(
                id: shelf[0].id,
                light: "Warm light sits on the near figures",
                thing: "A small dog by the hem",
                word: "quiet"
            )
        ]
        doc.memoryCards = [
            MemoryCard(id: "\(shelf[0].id)|van", workId: shelf[0].id, word: "van", box: 1, due: day),
            MemoryCard(id: "\(shelf[1].id)|fighting", workId: shelf[1].id, word: "Fighting", box: 1, due: day)
        ]
        doc.studioTool = .face
    }

    private static func uniqueIDs(_ ids: [String]) -> [String] {
        var seen: [String] = []
        for id in ids where seen.contains(id) == false {
            seen.append(id)
        }
        return seen
    }

    private static func sampleLexemes(from shelf: [Work]) -> [Lexeme] {
        var rows: [Lexeme] = []
        func take(_ work: Work, field: FurrowField, faced: Bool, pinned: Bool) {
            let tokens = Stichos.tokens(in: work.line(for: field))
            guard let word = tokens.dropFirst().first ?? tokens.first else { return }
            let key = word.lowercased()
            guard rows.contains(where: { $0.id == key }) == false else { return }
            rows.append(
                Lexeme(
                    id: key,
                    catalog: word,
                    retrograde: Stichos.letterReverse(word),
                    faceCount: faced ? 1 : 0,
                    yawCount: faced ? 0 : 1,
                    pinned: pinned,
                    workIds: [work.id]
                )
            )
        }
        if let first = shelf.first {
            take(first, field: first.lineReady(.artist) ? .artist : .title, faced: true, pinned: true)
        }
        if shelf.count > 1 {
            let second = shelf[1]
            take(second, field: second.lineReady(.title) ? .title : .artist, faced: false, pinned: false)
        }
        return rows
    }
}

enum FurrowSheet: Equatable, Identifiable, Sendable {
    case none
    case explore
    case saved
    case settings
    case lexicon
    case hangs
    case ledger
    case rooms
    case pairs
    case notices
    case checkers
    case library

    var id: String {
        switch self {
        case .none: "none"
        case .explore: "explore"
        case .saved: "saved"
        case .settings: "settings"
        case .lexicon: "lexicon"
        case .hangs: "hangs"
        case .ledger: "ledger"
        case .rooms: "rooms"
        case .pairs: "pairs"
        case .notices: "notices"
        case .checkers: "checkers"
        case .library: "library"
        }
    }
}
