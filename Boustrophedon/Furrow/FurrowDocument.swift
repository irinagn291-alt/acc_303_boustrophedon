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
            focusedWorkId: nil
        )
    }
}
