import XCTest
@testable import Boustrophedon

@MainActor
final class BoustrophedonTests: XCTestCase {
    private func store(_ works: [Work], furrow: Furrow? = nil, fold: Boustrophedon = .idle) -> FurrowStore {
        let suite = "bph.tests.\(UUID().uuidString)"
        UserDefaults(suiteName: suite)?.removePersistentDomain(forName: suite)
        var doc = FurrowDocument.empty()
        doc.works = works
        if var first = doc.works.first {
            first.fold = fold
            doc.works[0] = first
            doc.liveWorkId = first.id
        }
        doc.liveFurrow = furrow
        let folder = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString, isDirectory: true)
        return FurrowStore(preview: doc, suiteName: suite, folder: folder)
    }

    func testShortFieldAndResetWriteLevel() {
        let short = Work(id: "a", identity: "a", maker: "Solo", title: "One", imageFile: "x.jpg", daykey: 202_401_01, fold: .idle)
        let crate = store([short])
        crate.turnFurrow()
        XCTAssertTrue(crate.document.levelActive)
        XCTAssertNil(crate.liveFurrow)
        crate.resetAllData()
        XCTAssertTrue(crate.document.levelActive)
        XCTAssertTrue(crate.turnableWorks.isEmpty)
    }

    func testQuizDrawsOnlyFromSavedWorks() {
        let crate = store([])
        crate.turnFurrow()
        XCTAssertTrue(crate.document.levelActive)
        XCTAssertNil(crate.liveFurrow)
    }

    func testTwoTokenGateAndOddIndexReversal() {
        let work = Work(id: "a", identity: "a", maker: "Jan van", title: "One", imageFile: "x.jpg", daykey: 202_401_01, fold: .idle)
        let crate = store([work])
        crate.turnFurrow()
        XCTAssertEqual(crate.fold, .turned)
        XCTAssertEqual(crate.liveFurrow?.field, .artist)
        XCTAssertEqual(crate.liveFurrow?.stichoi[0].shown, "Jan")
        XCTAssertEqual(crate.liveFurrow?.stichoi[1].shown, Stichos.letterReverse("van"))
        XCTAssertTrue(crate.liveFurrow?.stichoi[1].isRetrograde ?? false)
    }

    func testFaceOnIdleRefused() {
        let work = Work(id: "a", identity: "a", maker: "Jan van", title: "Wide Title", imageFile: "x.jpg", daykey: 202_401_01, fold: .idle)
        let crate = store([work], fold: .idle)
        XCTAssertFalse(crate.faceStichos(1))
        XCTAssertTrue(crate.document.faceMarks.isEmpty)
    }

    func testSecondTurnWhileTurnedRefused() {
        let first = Work(id: "a", identity: "a", maker: "Jan van", title: "Wide Title", imageFile: "x.jpg", daykey: 202_401_01, fold: .idle)
        let second = Work(id: "b", identity: "b", maker: "Hans Holbein", title: "Other Picture", imageFile: "y.jpg", daykey: 202_401_01, fold: .idle)
        let crate = store([first, second])
        crate.turnFurrow()
        let id = crate.liveWork?.id
        crate.turnFurrow()
        XCTAssertEqual(crate.liveWork?.id, id)
        XCTAssertEqual(crate.fold, .turned)
    }

    func testMissKeepsFurrowAndLastFaceFolds() {
        let work = Work(id: "a", identity: "a", maker: "Jan van", title: "One", imageFile: "x.jpg", daykey: 202_401_01, fold: .idle)
        let crate = store([work])
        crate.turnFurrow()
        crate.yawStichos(0)
        XCTAssertEqual(crate.fold, .turned)
        XCTAssertEqual(crate.yawCount, 1)
        XCTAssertTrue(crate.liveFurrow?.stichoi[0].isCooled ?? false)
        XCTAssertTrue(crate.faceStichos(1))
        XCTAssertEqual(crate.fold, .faced)
        XCTAssertTrue(crate.turnableWorks.isEmpty)
    }

    func testRetractFoldsFacedBackAndDuplicateFocus() {
        let work = Work(id: "a", identity: "NG1", maker: "Jan van", title: "Wide Title", imageFile: "x.jpg", daykey: 202_401_01, fold: .idle)
        let crate = store([work])
        crate.turnFurrow()
        _ = crate.faceStichos(1)
        XCTAssertEqual(crate.fold, .faced)
        crate.retractNewestMark()
        XCTAssertEqual(crate.fold, .turned)
        crate.saveWork(work)
        XCTAssertEqual(crate.works.count, 1)
        XCTAssertEqual(crate.document.focusedWorkId, "a")
    }

    func testPersistenceRoundTrip() async {
        let suite = "bph.round.\(UUID().uuidString)"
        let folder = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString, isDirectory: true)
        let work = Work(id: "a", identity: "a", maker: "Jan van", title: "Wide Title", imageFile: "x.jpg", daykey: 202_401_01, fold: .idle)
        let first = FurrowStore(preview: {
            var doc = FurrowDocument.empty()
            doc.works = [work]
            return doc
        }(), suiteName: suite, folder: folder)
        first.turnFurrow()
        first.flush()
        try? await Task.sleep(for: .milliseconds(80))
        let vault = FurrowVault(suiteName: suite, folder: folder)
        let loaded = await vault.load()
        XCTAssertEqual(loaded.works.first?.fold, .turned)
        XCTAssertNotNil(loaded.liveFurrow)
    }

    func testReviewOpensDifferentScreens() {
        let crate = store([])
        crate.applyReview(.today)
        XCTAssertEqual(crate.sheet, .none)
        crate.applyReview(.log)
        XCTAssertEqual(crate.sheet, .saved)
        crate.applyReview(.goals)
        XCTAssertEqual(crate.sheet, .settings)
        crate.applyReview(.explore)
        XCTAssertEqual(crate.sheet, .explore)
    }

    func testReviewScreenParser() {
        XCTAssertEqual(ReviewScreenKey.parse(["-ReviewScreen", "today"]), .today)
        XCTAssertEqual(ReviewScreenKey.parse(["-ReviewScreen", "log"]), .log)
        XCTAssertEqual(ReviewScreenKey.parse(["-ReviewScreen", "goals"]), .goals)
        XCTAssertEqual(ReviewScreenKey.parse(["-ReviewScreen", "explore"]), .explore)
        XCTAssertNil(ReviewScreenKey.parse(["-ReviewScreen", "unknown"]))
        XCTAssertNil(ReviewScreenKey.parse([]))
    }

    func testYawMarksReviewableAndArtistXorTitle() {
        let work = Work(id: "a", identity: "odd", maker: "Solo", title: "The Hay Wain", imageFile: "x.jpg", daykey: 202_401_01, fold: .idle)
        XCTAssertEqual(work.chosenField(), .title)
        let crate = store([work])
        crate.turnFurrow()
        crate.yawStichos(0)
        XCTAssertEqual(crate.document.yawMarks.count, 1)
        XCTAssertEqual(crate.liveFurrow?.field, .title)
    }

    func testWorkAndDocumentDecodeMissingKeys() throws {
        let workJSON = """
        {"id":"a","identity":"a","maker":"Jan van","title":"One","imageFile":"x.jpg","daykey":20240101,"fold":"idle"}
        """
        let work = try JSONDecoder().decode(Work.self, from: Data(workJSON.utf8))
        XCTAssertEqual(work.yearLabel, "")
        XCTAssertEqual(work.curatorialLine, "")
        XCTAssertEqual(work.userNote, "")
        let docJSON = """
        {"schemaVersion":1,"works":[],"faceMarks":[],"yawMarks":[],"cachedWorks":[],"levelActive":false,"onboardingComplete":false,"markSeq":0}
        """
        let doc = try JSONDecoder().decode(FurrowDocument.self, from: Data(docJSON.utf8))
        XCTAssertFalse(doc.drillBlind)
        XCTAssertNil(doc.lineScope)
        XCTAssertEqual(doc.livePassFloor, 0)
        XCTAssertEqual(doc.studioTool, .face)
        XCTAssertFalse(doc.studioPlanted)
        XCTAssertNil(doc.daySession)
        XCTAssertTrue(doc.coverAttempts.isEmpty)
        XCTAssertTrue(doc.roomMarks.isEmpty)
        XCTAssertTrue(doc.pairNotes.isEmpty)
        XCTAssertTrue(doc.notices.isEmpty)
        XCTAssertEqual(doc.checkersWins, 0)
        XCTAssertEqual(doc.checkersMatch.men.compactMap { $0 }.count, 24)
        XCTAssertTrue(doc.memoryCards.isEmpty)
        XCTAssertTrue(doc.hangs.isEmpty)
        XCTAssertTrue(doc.lexemes.isEmpty)
        XCTAssertEqual(work.studioLine, "")
    }

    func testStarterCrateLeavesWelcomeAndALiveLine() {
        let doc = FurrowStore.starterCrate(.empty())
        XCTAssertEqual(doc.works.count, 6)
        XCTAssertFalse(doc.onboardingComplete)
        XCTAssertNotNil(doc.liveFurrow)
        XCTAssertEqual(doc.works.first?.fold, .turned)
        XCTAssertFalse(doc.faceMarks.isEmpty)
        XCTAssertEqual(GalleryShelf.works(daykey: 202_401_01).count, 50)
    }

    func testCuratorialScopeReopenAndNote() {
        var work = Work(
            id: "a",
            identity: "NG1",
            maker: "Jan van",
            title: "Wide Title",
            imageFile: "x.jpg",
            daykey: 202_401_01,
            fold: .idle,
            curatorialLine: "Oil on oak panel in a quiet room"
        )
        let crate = store([work])
        XCTAssertTrue(crate.setLineScope(.curatorial))
        XCTAssertEqual(crate.fold, .turned)
        XCTAssertEqual(crate.liveFurrow?.field, .curatorial)
        XCTAssertGreaterThan(crate.liveFurrow?.stichoi.count ?? 0, 2)
        crate.reopenForPractice(id: work.id, field: .title)
        XCTAssertEqual(crate.liveFurrow?.field, .title)
        crate.updateNote(id: work.id, note: "Look at the mirror")
        XCTAssertEqual(crate.works.first?.userNote, "Look at the mirror")
        XCTAssertTrue(crate.setLineScope(.artist))
        XCTAssertEqual(crate.liveFurrow?.field, .artist)
        work.maker = "Solo"
        let short = store([work])
        short.turnFurrow()
        XCTAssertFalse(short.setLineScope(.artist))
        XCTAssertNotEqual(short.liveFurrow?.field, .artist)
    }

    func testCustomEntryAndBlindDrill() {
        let crate = store([])
        XCTAssertFalse(crate.addCustomEntry(title: "One", maker: "Solo", era: "Modern", caption: "Short"))
        XCTAssertTrue(crate.works.isEmpty)
        XCTAssertTrue(crate.addCustomEntry(title: "One", maker: "Solo", era: "Modern", caption: "A quiet blue room"))
        XCTAssertEqual(crate.works.count, 1)
        XCTAssertEqual(crate.fold, .turned)
        XCTAssertEqual(crate.liveFurrow?.field, .curatorial)
        crate.setDrillBlind(true)
        XCTAssertTrue(crate.document.drillBlind)
        crate.yawStichos(0)
        _ = crate.faceStichos(1)
        XCTAssertEqual(crate.accuracyPercent, 50)
        XCTAssertGreaterThanOrEqual(crate.practiceStreak, 1)
    }

    func testRetractIgnoresMarksFromAnEarlierPass() {
        let work = Work(id: "a", identity: "a", maker: "Jan van", title: "Wide Title", imageFile: "x.jpg", daykey: 202_401_01, fold: .idle)
        let crate = store([work])
        crate.turnFurrow()
        XCTAssertTrue(crate.faceStichos(1))
        XCTAssertTrue(crate.setLineScope(.title))
        XCTAssertEqual(crate.faceCount, 1)
        XCTAssertFalse(crate.canRetract)
        crate.retractNewestMark()
        XCTAssertEqual(crate.faceCount, 1)
        XCTAssertEqual(crate.fold, .turned)
    }

    func testCoverRoomAndPair() {
        let graded = CoverCheck.grade(typed: "One Four", line: "One Two Three Four")
        XCTAssertEqual(graded?.hits, ["One", "Four"])
        XCTAssertEqual(graded?.missing, ["Two", "Three"])
        XCTAssertEqual(graded?.full, false)
        XCTAssertNil(CoverCheck.grade(typed: "Solo", line: "Solo"))
        let first = Work(
            id: "a",
            identity: "a",
            maker: "Jan van",
            title: "One Two Three Four",
            imageFile: "x.jpg",
            daykey: 202_401_01,
            fold: .idle,
            roomLabel: "Northern rooms"
        )
        let second = Work(
            id: "b",
            identity: "b",
            maker: "Hans Holbein",
            title: "Wide Title",
            imageFile: "y.jpg",
            daykey: 202_401_01,
            fold: .idle,
            roomLabel: "Northern rooms"
        )
        let crate = store([first, second])
        crate.turnFurrow()
        XCTAssertTrue(crate.setLineScope(.title))
        XCTAssertEqual(crate.fileCover(typed: "One Two Three Four")?.full, true)
        XCTAssertEqual(crate.document.coverAttempts.count, 1)
        crate.setRoomWalked(title: "Northern rooms", walked: true)
        XCTAssertEqual(crate.roomsWalked, 1)
        XCTAssertEqual(crate.roomRows.first?.minutes, 10)
        crate.shiftRoomMinutes(title: "Northern rooms", delta: 5)
        XCTAssertEqual(crate.roomRows.first?.minutes, 15)
        XCTAssertFalse(crate.savePair(leftId: first.id, rightId: first.id, body: "Same painting here"))
        XCTAssertTrue(crate.savePair(leftId: first.id, rightId: second.id, body: "Both sit in a quiet room"))
        XCTAssertEqual(crate.document.pairNotes.count, 1)
        XCTAssertFalse(crate.saveNotice(workId: first.id, light: "Warm", thing: "", word: ""))
        XCTAssertTrue(crate.saveNotice(workId: first.id, light: "Warm light on the hem", thing: "A small dog", word: "dog"))
        XCTAssertEqual(crate.document.notices.count, 1)
        XCTAssertTrue(crate.saveNotice(workId: first.id, light: "Cooler light now", thing: "A small dog", word: "dog"))
        XCTAssertEqual(crate.document.notices.count, 1)
        XCTAssertEqual(crate.document.notices.first?.light, "Cooler light now")
    }

    func testAMissIsDueTomorrowAndAFaceWaits() {
        let work = Work(id: "a", identity: "a", maker: "Jan van Eyck", title: "Wide Title", imageFile: "x.jpg", daykey: 202_401_01, fold: .idle)
        let crate = store([work])
        crate.turnFurrow()
        crate.setLineScope(.artist)
        crate.yawStichos(0)
        let missed = crate.document.memoryCards.first { $0.word == "Jan" }
        XCTAssertEqual(missed?.box, 1)
        XCTAssertEqual(missed?.due, DayKey.adding(1, to: DayKey.current()))
        let retrograde = crate.liveFurrow?.stichoi.first { $0.isRetrograde }?.index ?? 1
        XCTAssertTrue(crate.faceStichos(retrograde))
        let held = crate.document.memoryCards.first { $0.word == "van" }
        XCTAssertEqual(held?.box, 1)
        XCTAssertGreaterThan(held?.due ?? 0, DayKey.current())
        XCTAssertEqual(GalleryShelf.works(daykey: 202_401_01).count, 50)
    }

    func testCheckersForcesTheJumpAndTheHouseReplies() {
        let opening = CheckersMatch.opening()
        XCTAssertEqual(opening.men.compactMap { $0 }.filter { $0.side == .player }.count, 12)
        XCTAssertEqual(CheckersRules.legal(opening).count, 7)
        var board = CheckersMatch(men: Array(repeating: nil, count: 64), turn: .player, lock: nil, winner: nil)
        let start = CheckersBoard.index(1, 2)
        let foe = CheckersBoard.index(2, 3)
        let land = CheckersBoard.index(3, 4)
        board.men[start] = CheckersMan(side: .player, king: false)
        board.men[foe] = CheckersMan(side: .house, king: false)
        let moves = CheckersRules.legal(board)
        XCTAssertEqual(moves.count, 1)
        XCTAssertEqual(moves.first?.to, land)
        XCTAssertEqual(moves.first?.jumped, foe)
        let jumped = CheckersRules.after(board, moves[0])
        XCTAssertNil(jumped.men[foe])
        XCTAssertEqual(jumped.men[land]?.side, .player)
        XCTAssertEqual(jumped.turn, .house)
        let crate = store([
            Work(id: "a", identity: "a", maker: "Jan van", title: "Wide Title", imageFile: "x.jpg", daykey: 202_401_01, fold: .idle)
        ])
        crate.newCheckersGame()
        let first = crate.checkersMoves[0]
        crate.playCheckers(from: first.from, to: first.to)
        XCTAssertEqual(crate.document.checkersMatch.turn, .player)
        XCTAssertNil(crate.document.checkersMatch.winner)
    }

    func testTodayCutsFiveStopsAndPutsTheMissFirst() {
        let works = Array(GalleryShelf.works(daykey: 202_401_01).prefix(4))
        let lexeme = Lexeme(
            id: "van",
            catalog: "van",
            retrograde: "nav",
            faceCount: 0,
            yawCount: 2,
            pinned: true,
            workIds: [works[0].id]
        )
        let route = [VisitStop(id: "s", workId: works[1].id, done: false)]
        let session = SessionPlan.make(daykey: 202_601_01, works: works, lexemes: [lexeme], route: route, markSeq: 4)
        XCTAssertEqual(session?.stops.map(\.kind), [.bench, .plough, .face, .route, .recall])
        XCTAssertEqual(session?.stops.first?.word.lowercased(), "van")
        XCTAssertEqual(session?.stops.first { $0.kind == .route }?.workId, works[1].id)
        XCTAssertEqual(session?.stops.last?.kind, .recall)
    }

    func testFaceStationFilesOnlyWhenTheLineIsClear() {
        let work = Work(id: "a", identity: "a", maker: "Jan van Eyck", title: "One Two Three Four", imageFile: "x.jpg", daykey: 202_401_01, fold: .idle)
        let crate = store([work])
        crate.prepareToday()
        let faceIndex = crate.document.daySession?.stops.firstIndex { $0.kind == .face } ?? 0
        crate.openStation(faceIndex)
        XCTAssertGreaterThan(crate.liveFurrow?.remainingRetrograde ?? 0, 1)
        let first = crate.liveFurrow?.stichoi.first { $0.isRetrograde }?.index ?? 0
        XCTAssertTrue(crate.faceStichos(first))
        XCTAssertEqual(crate.document.daySession?.stops.first { $0.kind == .face }?.done, false)
        while let next = crate.liveFurrow?.stichoi.first(where: \.isRetrograde)?.index {
            XCTAssertTrue(crate.faceStichos(next))
        }
        XCTAssertEqual(crate.document.daySession?.stops.first { $0.kind == .face }?.done, true)
    }

    func testPrepareTodayKeepsTheOpenStop() {
        let works = Array(GalleryShelf.works(daykey: 202_401_01).prefix(4))
        let crate = store(works)
        crate.prepareToday()
        XCTAssertEqual(crate.document.daySession?.stops.count, 5)
        crate.openStation(2)
        let cursor = crate.document.daySession?.cursor
        crate.prepareToday()
        XCTAssertEqual(crate.document.daySession?.cursor, cursor)
        XCTAssertEqual(crate.document.daySession?.daykey, DayKey.current())
    }

    func testEnsureStudioKeepsTheOpenLine() {
        var doc = FurrowDocument.empty()
        doc.works = Array(GalleryShelf.works(daykey: 202_401_01).prefix(4))
        let work = doc.works[0]
        doc.liveWorkId = work.id
        doc.liveFurrow = Furrow.oxTurn(workId: work.id, field: .artist, line: work.maker)
        let planted = FurrowStore.ensureStudio(doc)
        XCTAssertTrue(planted.studioPlanted)
        XCTAssertEqual(planted.hangs.count, 1)
        XCTAssertFalse(planted.route.isEmpty)
        XCTAssertFalse(planted.lexemes.isEmpty)
        XCTAssertEqual(planted.liveWorkId, work.id)
        XCTAssertEqual(planted.liveFurrow?.workId, work.id)
        XCTAssertEqual(planted.works.count, 4)
        var cleared = planted
        cleared.hangs = []
        let kept = FurrowStore.ensureStudio(cleared)
        XCTAssertTrue(kept.hangs.isEmpty)
    }

    func testPloughReadsOutThenBack() {
        let line = "One Two Three Four Five Six"
        let course = PloughLayout.course(workId: "a", field: .title, line: line)
        let row = course?.cells.filter { $0.row == 1 }.sorted { $0.visualSlot < $1.visualSlot }
        XCTAssertEqual(row?.map(\.tokenIndex), [5, 4])
        let work = Work(
            id: "a",
            identity: "a",
            maker: "Jan van",
            title: line,
            imageFile: "x.jpg",
            daykey: 202_401_01,
            fold: .idle
        )
        let crate = store([work])
        crate.turnFurrow()
        XCTAssertTrue(crate.setLineScope(.title))
        XCTAssertTrue(crate.openPlough())
        XCTAssertFalse(crate.tapPlough(tokenIndex: 1))
        XCTAssertEqual(crate.document.livePlough?.nextToken, 0)
        XCTAssertEqual(crate.document.livePlough?.misses, 1)
        let count = crate.document.livePlough?.cells.count ?? 0
        for index in 0..<count {
            XCTAssertTrue(crate.tapPlough(tokenIndex: index))
        }
        XCTAssertNil(crate.document.livePlough)
        XCTAssertEqual(crate.document.ploughPasses.count, 1)
        XCTAssertEqual(crate.fold, .turned)
    }

    func testBenchSolvesAndFacesTheWord() {
        let work = Work(id: "a", identity: "a", maker: "Jan van", title: "Wide Title", imageFile: "x.jpg", daykey: 202_401_01, fold: .idle)
        let crate = store([work])
        crate.turnFurrow()
        XCTAssertTrue(crate.setLineScope(.artist))
        XCTAssertTrue(crate.openBench())
        XCTAssertEqual(crate.document.liveBench?.catalog, "van")
        let wrong = crate.document.liveBench?.tray.first { $0.letter != "v" }
        XCTAssertFalse(crate.placeBench(tileId: wrong?.id ?? ""))
        XCTAssertEqual(crate.document.liveBench?.misses, 1)
        XCTAssertTrue(crate.document.liveBench?.placed.isEmpty ?? false)
        for letter in ["v", "a", "n"] {
            let tile = crate.document.liveBench?.tray.first { $0.letter == letter }
            XCTAssertTrue(crate.placeBench(tileId: tile?.id ?? ""))
        }
        XCTAssertNil(crate.document.liveBench)
        XCTAssertEqual(crate.document.benchAttempts.count, 1)
        XCTAssertEqual(crate.fold, .faced)
        XCTAssertEqual(crate.document.lexemes.first { $0.id == "van" }?.faceCount, 1)
    }

    func testHangRouteDraftAndLexeme() {
        let work = Work(id: "a", identity: "a", maker: "Jan van", title: "Wide Title", imageFile: "x.jpg", daykey: 202_401_01, fold: .idle)
        let crate = store([work])
        XCTAssertNil(crate.createHang(title: "  "))
        let hang = crate.createHang(title: "North wall")
        XCTAssertNotNil(hang)
        crate.addWork(work.id, toHang: hang ?? "")
        crate.addWork(work.id, toHang: hang ?? "")
        XCTAssertEqual(crate.document.hangs.first?.workIds, [work.id])
        XCTAssertTrue(crate.addToRoute(workId: work.id))
        XCTAssertFalse(crate.addToRoute(workId: work.id))
        let stop = crate.document.route.first?.id ?? ""
        crate.toggleStop(id: stop)
        XCTAssertTrue(crate.document.route.first?.done ?? false)
        XCTAssertFalse(crate.saveDraft(workId: work.id, title: "Short", body: "One"))
        XCTAssertTrue(crate.saveDraft(workId: work.id, title: "Mirror", body: "A small dog waits"))
        let draft = crate.document.drafts.first?.id ?? ""
        XCTAssertTrue(crate.turnDraft(id: draft))
        XCTAssertEqual(crate.liveFurrow?.field, .studio)
        XCTAssertEqual(crate.works.first?.studioLine, "A small dog waits")
        crate.turnFurrow()
        crate.yawStichos(0)
        XCTAssertEqual(crate.document.lexemes.first { $0.catalog == "A" }?.yawCount, 1)
        crate.setLexemePinned(id: "a", pinned: true)
        XCTAssertTrue(crate.document.lexemes.first { $0.id == "a" }?.pinned ?? false)
    }
}
