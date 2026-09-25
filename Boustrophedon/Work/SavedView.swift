import SwiftUI

/// Role: Work. Faced paintings and reviewable YawMarks.
struct SavedView: View {
    @Bindable var store: FurrowStore

    var body: some View {
        NavigationStack {
            Group {
                if store.facedWorks.isEmpty && store.document.yawMarks.isEmpty {
                    QuietPage(
                        art: "bph_EmptyList",
                        headline: "Nothing faced yet.",
                        line: "Lay a caption, then tap the backward words.",
                        actionTitle: "Back to the line"
                    ) {
                        store.present(.none)
                    }
                } else {
                    list
                }
            }
            .background(OxPalette.background.ignoresSafeArea())
            .navigationTitle("Saved")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        store.present(.none)
                    } label: {
                        Image(systemName: "xmark")
                            .frame(width: OxSpace.hit, height: OxSpace.hit)
                            .contentShape(Rectangle())
                    }
                    .accessibilityLabel("Close")
                }
            }
        }
    }

    private var list: some View {
        List {
            Section("Faced") {
                ForEach(store.facedWorks) { work in
                    HStack(alignment: .center, spacing: OxSpace.sm) {
                        ShelfPicture(work: work, art: "bph_FacedCaption")
                            .frame(width: OxSpace.sm * 5, height: OxSpace.lg * 2)
                            .clipShape(RoundedRectangle(cornerRadius: OxRadius.chip, style: .continuous))
                        VStack(alignment: .leading, spacing: OxSpace.xs) {
                            Text(work.title)
                                .font(OxType.headline)
                                .foregroundStyle(OxPalette.ink)
                                .lineLimit(1)
                            Text(work.maker)
                                .font(OxType.caption)
                                .foregroundStyle(OxPalette.muted)
                                .lineLimit(1)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .frame(minHeight: OxSpace.hit)
                    .listRowBackground(OxPalette.surface)
                }
            }
            Section("Yaws") {
                ForEach(store.document.yawMarks) { mark in
                    let name = store.works.first { $0.id == mark.workId }?.title ?? "Painting"
                    VStack(alignment: .leading, spacing: OxSpace.xs) {
                        Text(name)
                            .font(OxType.headline)
                            .foregroundStyle(OxPalette.ink)
                            .lineLimit(1)
                        Text(yawCaption(mark))
                            .font(OxType.caption)
                            .foregroundStyle(OxPalette.muted)
                            .lineLimit(1)
                    }
                    .frame(minHeight: OxSpace.hit, alignment: .leading)
                    .listRowBackground(OxPalette.surface)
                }
            }
            Section {
                HStack(alignment: .firstTextBaseline, spacing: OxSpace.md) {
                    VStack(alignment: .leading, spacing: OxSpace.xs) {
                        Text(OxFigures.count(store.faceCount))
                            .font(OxType.title)
                            .foregroundStyle(OxPalette.ink)
                            .monospacedDigit()
                            .lineLimit(1)
                            .layoutPriority(1)
                        Text("Faces")
                            .font(OxType.caption)
                            .foregroundStyle(OxPalette.muted)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    VStack(alignment: .leading, spacing: OxSpace.xs) {
                        Text(OxFigures.count(store.yawCount))
                            .font(OxType.headline)
                            .foregroundStyle(OxPalette.ink)
                            .monospacedDigit()
                            .lineLimit(1)
                        Text("Yaws")
                            .font(OxType.caption)
                            .foregroundStyle(OxPalette.muted)
                    }
                }
                .listRowBackground(OxPalette.surface)
            }
        }
        .scrollContentBackground(.hidden)
        .contentMargins(.bottom, OxSpace.lg, for: .scrollContent)
    }

    private func yawCaption(_ mark: YawMark) -> String {
        let word = OxFigures.count(mark.stichosIndex + 1)
        let day = OxFigures.daykey(mark.daykey)
        return "Word \(word) on \(day)"
    }
}
