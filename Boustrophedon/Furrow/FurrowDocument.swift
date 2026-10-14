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
            livePassFloor: 0
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
        livePassFloor: Int
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
    }
}
