import Foundation

/// Role: Furrow. Launch keys after onboarding. Not tabs.
enum ReviewScreenKey: Equatable, Sendable {
    case today
    case log
    case goals
    case explore

    static func parse(_ arguments: [String]) -> ReviewScreenKey? {
        guard let flag = arguments.firstIndex(of: "-ReviewScreen") else { return nil }
        let next = flag + 1
        guard arguments.indices.contains(next) else { return nil }
        switch arguments[next] {
        case "today": return .today
        case "log": return .log
        case "goals": return .goals
        case "explore": return .explore
        default: return nil
        }
    }
}
