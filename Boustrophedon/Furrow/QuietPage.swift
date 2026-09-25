import SwiftUI

/// Role: Furrow. Full-page empty. Generated cutout, one headline, one line, bottom CTA.
struct QuietPage: View {
    let art: String
    let headline: String
    let line: String
    let actionTitle: String
    let action: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: OxSpace.md) {
            Spacer(minLength: OxSpace.lg)
            Image(art)
                .resizable()
                .scaledToFit()
                .frame(maxWidth: OxSpace.lg * 7, maxHeight: OxSpace.lg * 7)
                .accessibilityHidden(true)
            Text(headline)
                .font(OxType.display(.large))
                .foregroundStyle(OxPalette.ink)
                .lineLimit(2)
            Text(line)
                .font(OxType.body)
                .foregroundStyle(OxPalette.muted)
            Spacer(minLength: OxSpace.lg)
            Button(actionTitle, action: action)
                .buttonStyle(FaceButtonStyle())
        }
        .padding(OxSpace.lg)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        .background(OxPalette.background.ignoresSafeArea())
    }
}
