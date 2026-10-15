import Foundation

/// Role: Furrow. One Codable projection. schemaVersion starts at 1. Level is a write, not a Work case.
struct FurrowDocument: Codable, Equatable, Sendable {
    var schemaVersion: Int
    var works: [Work]
    var liveFurrow: Furrow?
    var liveWorkId: String?
    var faceMarks: [FaceMark]
    var yawMarks: [YawMark]
    var cachedWorks: [Work]
    var levelActive: Bool
    var onboardingComplete: Bool
    var markSeq: Int
    var focusedWorkId: String?
    var drillBlind: Bool
    var lineScope: FurrowField?
    var livePassFloor: Int
    var studioTool: StudioTool
    var livePlough: PloughCourse?
    var liveBench: BenchCourse?
    var ploughPasses: [PloughPass]
    var benchAttempts: [BenchAttempt]
    var lexemes: [Lexeme]
    var hangs: [Hang]
    var route: [VisitStop]
    var drafts: [CaptionDraft]
    var dayNotes: [DayNote]
    var studioPlanted: Bool
    var daySession: DaySession?
    var coverAttempts: [CoverAttempt]
    var roomMarks: [RoomMark]
    var pairNotes: [PairNote]
    var notices: [Notice]
    var checkersMatch: CheckersMatch
    var checkersWins: Int
    var checkersLosses: Int
    var memoryCards: [MemoryCard]

    static let currentSchema = 1

    static func empty() -> FurrowDocument {
        FurrowDocument(
            schemaVersion: currentSchema,
            works: [],
            liveFurrow: nil,
            liveWorkId: nil,
            faceMarks: [],
            yawMarks: [],
            cachedWorks: [],
            levelActive: false,
            onboardingComplete: false,
            markSeq: 0,
            focusedWorkId: nil,
            drillBlind: false,
            lineScope: nil,
            livePassFloor: 0,
            studioTool: .face,
            livePlough: nil,
            liveBench: nil,
            ploughPasses: [],
            benchAttempts: [],
            lexemes: [],
            hangs: [],
            route: [],
            drafts: [],
            dayNotes: [],
            studioPlanted: false,
            daySession: nil,
            coverAttempts: [],
            roomMarks: [],
            pairNotes: [],
            notices: [],
            checkersMatch: .opening(),
            checkersWins: 0,
            checkersLosses: 0,
            memoryCards: []
        )
    }

    enum CodingKeys: String, CodingKey {
        case schemaVersion
        case works
        case liveFurrow
        case liveWorkId
        case faceMarks
        case yawMarks
        case cachedWorks
        case levelActive
        case onboardingComplete
        case markSeq
        case focusedWorkId
        case drillBlind
        case lineScope
        case livePassFloor
        case studioTool
        case livePlough
        case liveBench
        case ploughPasses
        case benchAttempts
        case lexemes
        case hangs
        case route
        case drafts
        case dayNotes
        case studioPlanted
        case daySession
        case coverAttempts
        case roomMarks
        case pairNotes
        case notices
        case checkersMatch
        case checkersWins
        case checkersLosses
        case memoryCards
    }

    init(
        schemaVersion: Int,
        works: [Work],
        liveFurrow: Furrow?,
        liveWorkId: String?,
        faceMarks: [FaceMark],
        yawMarks: [YawMark],
        cachedWorks: [Work],
        levelActive: Bool,
        onboardingComplete: Bool,
        markSeq: Int,
        focusedWorkId: String?,
        drillBlind: Bool,
        lineScope: FurrowField?,
        livePassFloor: Int,
        studioTool: StudioTool,
        livePlough: PloughCourse?,
        liveBench: BenchCourse?,
        ploughPasses: [PloughPass],
        benchAttempts: [BenchAttempt],
        lexemes: [Lexeme],
        hangs: [Hang],
        route: [VisitStop],
        drafts: [CaptionDraft],
        dayNotes: [DayNote],
        studioPlanted: Bool,
        daySession: DaySession?,
        coverAttempts: [CoverAttempt],
        roomMarks: [RoomMark],
        pairNotes: [PairNote],
        notices: [Notice],
        checkersMatch: CheckersMatch,
        checkersWins: Int,
        checkersLosses: Int,
        memoryCards: [MemoryCard]
    ) {
        self.schemaVersion = schemaVersion
        self.works = works
        self.liveFurrow = liveFurrow
        self.liveWorkId = liveWorkId
        self.faceMarks = faceMarks
        self.yawMarks = yawMarks
        self.cachedWorks = cachedWorks
        self.levelActive = levelActive
        self.onboardingComplete = onboardingComplete
        self.markSeq = markSeq
        self.focusedWorkId = focusedWorkId
        self.drillBlind = drillBlind
        self.lineScope = lineScope
        self.livePassFloor = livePassFloor
        self.studioTool = studioTool
        self.livePlough = livePlough
        self.liveBench = liveBench
        self.ploughPasses = ploughPasses
        self.benchAttempts = benchAttempts
        self.lexemes = lexemes
        self.hangs = hangs
        self.route = route
        self.drafts = drafts
        self.dayNotes = dayNotes
        self.studioPlanted = studioPlanted
        self.daySession = daySession
        self.coverAttempts = coverAttempts
        self.roomMarks = roomMarks
        self.pairNotes = pairNotes
        self.notices = notices
        self.checkersMatch = checkersMatch
        self.checkersWins = checkersWins
        self.checkersLosses = checkersLosses
        self.memoryCards = memoryCards
    }

    init(from decoder: Decoder) throws {
        let box = try decoder.container(keyedBy: CodingKeys.self)
        schemaVersion = try box.decodeIfPresent(Int.self, forKey: .schemaVersion) ?? Self.currentSchema
        works = try box.decodeIfPresent([Work].self, forKey: .works) ?? []
        liveFurrow = try box.decodeIfPresent(Furrow.self, forKey: .liveFurrow)
        liveWorkId = try box.decodeIfPresent(String.self, forKey: .liveWorkId)
        faceMarks = try box.decodeIfPresent([FaceMark].self, forKey: .faceMarks) ?? []
        yawMarks = try box.decodeIfPresent([YawMark].self, forKey: .yawMarks) ?? []
        cachedWorks = try box.decodeIfPresent([Work].self, forKey: .cachedWorks) ?? []
        levelActive = try box.decodeIfPresent(Bool.self, forKey: .levelActive) ?? false
        onboardingComplete = try box.decodeIfPresent(Bool.self, forKey: .onboardingComplete) ?? false
        markSeq = try box.decodeIfPresent(Int.self, forKey: .markSeq) ?? 0
        focusedWorkId = try box.decodeIfPresent(String.self, forKey: .focusedWorkId)
        drillBlind = try box.decodeIfPresent(Bool.self, forKey: .drillBlind) ?? false
        lineScope = try box.decodeIfPresent(FurrowField.self, forKey: .lineScope)
        livePassFloor = try box.decodeIfPresent(Int.self, forKey: .livePassFloor) ?? 0
        studioTool = try box.decodeIfPresent(StudioTool.self, forKey: .studioTool) ?? .face
        livePlough = try box.decodeIfPresent(PloughCourse.self, forKey: .livePlough)
        liveBench = try box.decodeIfPresent(BenchCourse.self, forKey: .liveBench)
        ploughPasses = try box.decodeIfPresent([PloughPass].self, forKey: .ploughPasses) ?? []
        benchAttempts = try box.decodeIfPresent([BenchAttempt].self, forKey: .benchAttempts) ?? []
        lexemes = try box.decodeIfPresent([Lexeme].self, forKey: .lexemes) ?? []
        hangs = try box.decodeIfPresent([Hang].self, forKey: .hangs) ?? []
        route = try box.decodeIfPresent([VisitStop].self, forKey: .route) ?? []
        drafts = try box.decodeIfPresent([CaptionDraft].self, forKey: .drafts) ?? []
        dayNotes = try box.decodeIfPresent([DayNote].self, forKey: .dayNotes) ?? []
        studioPlanted = try box.decodeIfPresent(Bool.self, forKey: .studioPlanted) ?? false
        daySession = try box.decodeIfPresent(DaySession.self, forKey: .daySession)
        coverAttempts = try box.decodeIfPresent([CoverAttempt].self, forKey: .coverAttempts) ?? []
        roomMarks = try box.decodeIfPresent([RoomMark].self, forKey: .roomMarks) ?? []
        pairNotes = try box.decodeIfPresent([PairNote].self, forKey: .pairNotes) ?? []
        notices = try box.decodeIfPresent([Notice].self, forKey: .notices) ?? []
        checkersMatch = try box.decodeIfPresent(CheckersMatch.self, forKey: .checkersMatch) ?? .opening()
        checkersWins = try box.decodeIfPresent(Int.self, forKey: .checkersWins) ?? 0
        checkersLosses = try box.decodeIfPresent(Int.self, forKey: .checkersLosses) ?? 0
        memoryCards = try box.decodeIfPresent([MemoryCard].self, forKey: .memoryCards) ?? []
    }

    func encode(to encoder: Encoder) throws {
        var box = encoder.container(keyedBy: CodingKeys.self)
        try box.encode(schemaVersion, forKey: .schemaVersion)
        try box.encode(works, forKey: .works)
        try box.encodeIfPresent(liveFurrow, forKey: .liveFurrow)
        try box.encodeIfPresent(liveWorkId, forKey: .liveWorkId)
        try box.encode(faceMarks, forKey: .faceMarks)
        try box.encode(yawMarks, forKey: .yawMarks)
        try box.encode(cachedWorks, forKey: .cachedWorks)
        try box.encode(levelActive, forKey: .levelActive)
        try box.encode(onboardingComplete, forKey: .onboardingComplete)
        try box.encode(markSeq, forKey: .markSeq)
        try box.encodeIfPresent(focusedWorkId, forKey: .focusedWorkId)
        try box.encode(drillBlind, forKey: .drillBlind)
        try box.encodeIfPresent(lineScope, forKey: .lineScope)
        try box.encode(livePassFloor, forKey: .livePassFloor)
        try box.encode(studioTool, forKey: .studioTool)
        try box.encodeIfPresent(livePlough, forKey: .livePlough)
        try box.encodeIfPresent(liveBench, forKey: .liveBench)
        try box.encode(ploughPasses, forKey: .ploughPasses)
        try box.encode(benchAttempts, forKey: .benchAttempts)
        try box.encode(lexemes, forKey: .lexemes)
        try box.encode(hangs, forKey: .hangs)
        try box.encode(route, forKey: .route)
        try box.encode(drafts, forKey: .drafts)
        try box.encode(dayNotes, forKey: .dayNotes)
        try box.encode(studioPlanted, forKey: .studioPlanted)
        try box.encodeIfPresent(daySession, forKey: .daySession)
        try box.encode(coverAttempts, forKey: .coverAttempts)
        try box.encode(roomMarks, forKey: .roomMarks)
        try box.encode(pairNotes, forKey: .pairNotes)
        try box.encode(notices, forKey: .notices)
        try box.encode(checkersMatch, forKey: .checkersMatch)
        try box.encode(checkersWins, forKey: .checkersWins)
        try box.encode(checkersLosses, forKey: .checkersLosses)
        try box.encode(memoryCards, forKey: .memoryCards)
    }
}
