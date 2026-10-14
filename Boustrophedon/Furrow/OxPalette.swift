import SwiftUI

/// Role: Furrow. One colour accessor. Views use these names; the catalog holds the same hex.
enum OxPalette {
    static let background = catalog("background", "#472414")
    static let surface = catalog("surface", "#6B4230")
    static let ink = catalog("ink", "#FFF6FC")
    static let accent = catalog("accent", "#FF6F2E")
    static let muted = catalog("muted", "#DBB19E")

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
