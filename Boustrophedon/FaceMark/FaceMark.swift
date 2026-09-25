import Foundation

/// Role: FaceMark. A true Face on a still-retrograde Stichos.
struct FaceMark: Codable, Equatable, Identifiable, Sendable {
    var id: String
    var workId: String
    var stichosIndex: Int
    var seq: Int
    var daykey: Int
}
