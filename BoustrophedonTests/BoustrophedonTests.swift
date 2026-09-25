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
}
