import SwiftUI
import UIKit

/// Role: Furrow. One colour accessor. Views use these names; the catalog holds the same hex.
enum OxPalette {
    static let background = catalog("background", "#472414")
    static let surface = catalog("surface", "#6B4230")
    static let ink = catalog("ink", "#FFF6FC")
    static let accent = catalog("accent", "#FF6F2E")
    static let muted = catalog("muted", "#F6DDD2")

    private static func catalog(_ name: String, _ token: String) -> Color {
        Color(name, bundle: token.isEmpty ? nil : .main)
    }
}

/// Role: Furrow. Navigation titles and the close mark stay cream on the brown bar.
enum OxChrome {
    static func apply() {
        let ink = UIColor(red: 1, green: 0xF6 / 255, blue: 0xFC / 255, alpha: 1)
        let background = UIColor(red: 0x47 / 255, green: 0x24 / 255, blue: 0x14 / 255, alpha: 1)
        let bar = UINavigationBarAppearance()
        bar.configureWithOpaqueBackground()
        bar.backgroundColor = background
        bar.titleTextAttributes = [.foregroundColor: ink]
        bar.largeTitleTextAttributes = [.foregroundColor: ink]
        bar.shadowColor = .clear
        let navigation = UINavigationBar.appearance()
        navigation.standardAppearance = bar
        navigation.scrollEdgeAppearance = bar
        navigation.compactAppearance = bar
        navigation.tintColor = ink
    }
}

/// Role: Furrow. One soft drop shadow. Hero tile only.
enum OxLift {
    static let color = OxPalette.ink.opacity(0.14)
    static let radius: CGFloat = OxSpace.sm
    static let y: CGFloat = OxSpace.xs
}
