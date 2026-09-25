import Foundation

/// Role: Turn. Samples a not-Faced Work whose chosen field still has two tokens.
enum Turn: Equatable, Sendable {
    case refused
    case level
    case opened(workId: String, field: FurrowField, furrow: Furrow)
}
