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
    }

    func testStarterCrateLeavesWelcomeAndALiveLine() {
        let doc = FurrowStore.starterCrate(.empty())
        XCTAssertEqual(doc.works.count, 6)
        XCTAssertFalse(doc.onboardingComplete)
        XCTAssertNotNil(doc.liveFurrow)
        XCTAssertEqual(doc.works.first?.fold, .turned)
        XCTAssertFalse(doc.faceMarks.isEmpty)
        XCTAssertEqual(GalleryShelf.works(daykey: 202_401_01).count, 24)
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
}
