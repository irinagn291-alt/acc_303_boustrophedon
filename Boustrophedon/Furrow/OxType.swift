import SwiftUI

/// Role: Furrow. Six SF Pro steps. Display stays short.
enum OxType {
    static func display(_ size: DynamicTypeSize) -> Font {
        let style: Font.TextStyle = size >= .accessibility5 ? .title2 : .title
        return Font.system(style, design: .default).weight(.bold)
    }

    static let title = Font.system(.title2, design: .default).weight(.semibold)
    static let headline = Font.system(.headline, design: .default)
    static let body = Font.system(.body, design: .default).weight(.medium)
    static let caption = Font.system(.footnote, design: .default).weight(.medium)
    static let micro = Font.system(.caption, design: .default)
}
