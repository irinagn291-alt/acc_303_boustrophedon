import Foundation

/// Role: Furrow. Artist XOR title, or the gallery inscription when the reader asks for it.
enum FurrowField: String, Codable, Equatable, Sendable, CaseIterable {
    case artist
    case title
    case curatorial
}
