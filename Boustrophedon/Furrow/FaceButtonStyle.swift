import SwiftUI

/// Role: Furrow. Primary Face. Default, pressed, disabled, loading. Destructive is a variant.
struct FaceButtonStyle: ButtonStyle {
    var isDestructive = false
    var isLoading = false
    var prominent = true

    @Environment(\.isEnabled) private var isEnabled
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    func makeBody(configuration: Configuration) -> some View {
        let pressed = configuration.isPressed
        return configuration.label
            .font(OxType.headline)
            .foregroundStyle(foreground)
            .opacity(isLoading ? 0 : 1)
            .frame(maxWidth: .infinity, minHeight: OxSpace.hit)
            .padding(.horizontal, OxSpace.sm)
            .background(
                RoundedRectangle(cornerRadius: OxRadius.card, style: .continuous)
                    .fill(fill)
            )
            .overlay {
                if isLoading {
                    ProgressView().tint(foreground)
                }
            }
            .contentShape(RoundedRectangle(cornerRadius: OxRadius.card, style: .continuous))
            .scaleEffect(reduceMotion ? 1 : (pressed && isEnabled ? OxMotion.pressScale : 1))
            .opacity(pressed && reduceMotion ? 0.72 : 1)
            .animation(.easeOut(duration: OxMotion.press), value: pressed)
    }

    private var fill: Color {
        if isEnabled == false { return OxPalette.surface }
        if isDestructive { return OxPalette.ink }
        if prominent { return OxPalette.accent }
        return OxPalette.surface
    }

    private var foreground: Color {
        if isEnabled == false { return OxPalette.muted }
        if isDestructive || prominent { return OxPalette.surface }
        return OxPalette.ink
    }
}

/// Role: Furrow. Press scale for chips and icon chrome. Reduce Motion fades.
struct OxTapStyle: ButtonStyle {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(reduceMotion ? 1 : (configuration.isPressed ? OxMotion.pressScale : 1))
            .opacity(configuration.isPressed && reduceMotion ? 0.72 : 1)
            .animation(.easeOut(duration: OxMotion.press), value: configuration.isPressed)
    }
}
