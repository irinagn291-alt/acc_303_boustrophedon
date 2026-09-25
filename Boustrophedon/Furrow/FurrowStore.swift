import Foundation
import Observation

/// Role: Furrow. One observable fold. Views call turnFurrow, faceStichos, yawStichos, retractNewestMark.
@MainActor
@Observable
final class FurrowStore {
    static let shared = FurrowStore()
    static let demoKey = "bph.demo.v1"

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
            initial = Self.applySimulatorSeed(initial, defaults: .standard)
        }
        self.document = initial
        publishLevel()
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
            let seeded = Self.applySimulatorSeed(loaded, defaults: .standard)
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
        persistSoon(immediate: true)
    }

    func flush() {
        persistSoon(immediate: true)
    }

    func turnFurrow() {
        if liveWork?.fold == .turned { return }
        document.levelActive = false
        let pool = document.works.filter { $0.fold != .faced }
        guard let picked = pool.first(where: { $0.chosenField() != nil }),
              let field = picked.chosenField(),
              let furrow = Furrow.oxTurn(workId: picked.id, field: field, line: picked.line(for: field))
        else {
            document.levelActive = true
            document.liveFurrow = nil
            document.liveWorkId = nil
            persistSoon(immediate: true)
            return
        }
        document.liveFurrow = furrow
        document.liveWorkId = picked.id
        mutateWork(id: picked.id) { $0.fold = .turned }
        persistSoon(immediate: true)
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
            document.liveFurrow = furrow
            if furrow.remainingRetrograde == 0 {
                mutateWork(id: furrow.workId) { $0.fold = .faced }
                if turnableWorks.isEmpty {
                    document.levelActive = true
                }
            }
            persistSoon(immediate: true)
            return true
        }
        yawStichos(index)
        return false
    }

    func yawStichos(_ index: Int) {
        guard liveWork?.fold == .turned else { return }
        guard var furrow = document.liveFurrow, furrow.stichoi.indices.contains(index) else { return }
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
        furrow = furrow.cools(index: index)
        document.liveFurrow = furrow
        persistSoon(immediate: true)
    }

    func retractNewestMark() {
        let lastFace = document.faceMarks.max(by: { $0.seq < $1.seq })
        let lastYaw = document.yawMarks.max(by: { $0.seq < $1.seq })
        if let face = lastFace, lastYaw == nil || face.seq > (lastYaw?.seq ?? 0) {
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
        return doc
        #else
        return loaded
        #endif
    }
}

enum FurrowSheet: Equatable, Sendable {
    case none
    case explore
    case saved
    case settings
}
