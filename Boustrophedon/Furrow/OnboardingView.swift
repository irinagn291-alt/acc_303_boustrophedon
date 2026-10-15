import SwiftUI

/// Role: Furrow. Three pages. Continue or Next at the bottom, full width.
struct OnboardingView: View {
    var finish: () -> Void
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var page = 0

    private let pages: [(art: String, title: String, line: String)] = [
        ("bph_Onboarding1", "Today is waiting.", "Five stops are already cut. Spell a miss, walk a line, face the backward words, take the next route stop, then recall a word."),
        ("bph_Onboarding2", "Three ways to read.", "Face sets a backward word right. Plough walks the line left, then back. Bench spells one word forward."),
        ("bph_Onboarding3", "Tomorrow cuts a new five.", "Cover writes a line from memory. Rooms and pairs stay with the book and the route. Today files when all five stops are done.")
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: OxSpace.md) {
            pageBody
            HStack(spacing: OxSpace.xs) {
                ForEach(pages.indices, id: \.self) { index in
                    RoundedRectangle(cornerRadius: OxRadius.chip, style: .continuous)
                        .fill(index == page ? OxPalette.ink : OxPalette.muted)
                        .frame(width: index == page ? OxSpace.lg : OxSpace.sm, height: OxSpace.xs)
                }
            }
            .accessibilityHidden(true)
            .padding(.horizontal, OxSpace.lg)
            Button(page == pages.count - 1 ? "Continue" : "Next") {
                if page == pages.count - 1 {
                    finish()
                } else {
                    page += 1
                }
            }
            .buttonStyle(FaceButtonStyle())
            .padding(.horizontal, OxSpace.lg)
            .padding(.bottom, OxSpace.lg)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        .background(OxPalette.background.ignoresSafeArea())
        .animation(reduceMotion ? nil : .easeOut(duration: OxMotion.press), value: page)
    }

    private var pageBody: some View {
        let item = pages[page]
        return VStack(alignment: .leading, spacing: OxSpace.md) {
            Image(item.art)
                .resizable()
                .scaledToFit()
                .frame(maxWidth: .infinity, maxHeight: OxSpace.band)
                .accessibilityHidden(true)
            Text(item.title)
                .font(OxType.display(.large))
                .foregroundStyle(OxPalette.ink)
                .lineLimit(2)
            Text(item.line)
                .font(OxType.body)
                .foregroundStyle(OxPalette.muted)
                .lineLimit(4)
            Spacer(minLength: OxSpace.lg)
        }
        .padding(.horizontal, OxSpace.lg)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
    }
}
