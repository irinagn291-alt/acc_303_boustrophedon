import Foundation

/// Role: Stichos. One token on the ox-plough line. Odd catalog indices start retrograde.
struct Stichos: Codable, Equatable, Identifiable, Sendable {
    var id: String
    var index: Int
    var catalog: String
    var shown: String
    var isRetrograde: Bool
    var isCooled: Bool

    static func letterReverse(_ word: String) -> String {
        String(word.reversed())
    }

    static func tokens(in line: String) -> [String] {
        line.split(whereSeparator: \.isWhitespace).map(String.init).filter { !$0.isEmpty }
    }
}
