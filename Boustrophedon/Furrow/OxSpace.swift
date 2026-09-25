import CoreGraphics

/// Role: Furrow. One 8 pt unit. Only multiples.
enum OxSpace {
    static let unit: CGFloat = 8
    static let xs: CGFloat = unit
    static let sm: CGFloat = unit * 2
    static let md: CGFloat = unit * 3
    static let lg: CGFloat = unit * 4
    static let xl: CGFloat = unit * 5
    static let hit: CGFloat = unit * 6
    static let band: CGFloat = unit * 32
}
