import SwiftUI

/// Role: Furrow. One colour accessor. Views use these names; the catalog holds the same hex.
enum OxPalette {
    static let background = catalog("background", "#FAF7F5")
    static let surface = catalog("surface", "#FEFEFD")
    static let ink = catalog("ink", "#392818")
    static let accent = catalog("accent", "#CC6D19")
    static let muted = catalog("muted", "#816C5A")

    private static func catalog(_ name: String, _ token: String) -> Color {
        Color(name, bundle: token.isEmpty ? nil : .main)
    }
}

/// Role: Furrow. One soft drop shadow. Hero tile only.
enum OxLift {
    static let color = OxPalette.ink.opacity(0.14)
    static let radius: CGFloat = OxSpace.sm
    static let y: CGFloat = OxSpace.xs
}
