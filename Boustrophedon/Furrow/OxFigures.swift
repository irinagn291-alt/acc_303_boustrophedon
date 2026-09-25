import Foundation

/// Role: Furrow. Counts and day keys go through NumberFormatter.
enum OxFigures {
    static func count(_ value: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.usesGroupingSeparator = true
        return formatter.string(from: NSNumber(value: value)) ?? "0"
    }

    static func daykey(_ value: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .none
        formatter.usesGroupingSeparator = false
        return formatter.string(from: NSNumber(value: value)) ?? ""
    }
}
