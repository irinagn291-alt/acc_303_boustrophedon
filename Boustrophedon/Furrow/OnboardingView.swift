import SwiftUI

/// Role: Furrow. Three pages. Continue or Next at the bottom, full width.
struct OnboardingView: View {
    var finish: () -> Void
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var page = 0

    private let pages: [(art: String, title: String, line: String)] = [
        ("bph_Onboarding1", "A line for captions.", "Save a National Gallery painting, then lay its maker or title."),
        ("bph_Onboarding2", "Face each backward word.", "Every other word runs backward. Tap it to set the letters right."),
        ("bph_Onboarding3", "Keep the faced line.", "Misses stay so you can review them. All of it stays on this device.")
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
