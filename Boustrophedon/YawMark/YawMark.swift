import Foundation

/// Role: YawMark. A miss. The Furrow stays ox-turned and the Stichos cools.
struct YawMark: Codable, Equatable, Identifiable, Sendable {
    var id: String
    var workId: String
    var stichosIndex: Int
    var seq: Int
    var daykey: Int
}
