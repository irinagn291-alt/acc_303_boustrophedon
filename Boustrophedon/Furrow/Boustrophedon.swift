import Foundation

/// Role: Furrow. Closed algebraic fold over a Work. A fourth case is a defect.
enum Boustrophedon: String, Codable, Equatable, Sendable, CaseIterable {
    case idle
    case turned
    case faced
}
