import SwiftUI

/// Role: Furrow. The whole local shelf, grouped by era, ready to enter today's crate.
struct LibraryView: View {
    @Bindable var store: FurrowStore
    var showsClose: Bool = true

    private var sections: [(era: String, works: [Work])] {
        let all = GalleryShelf.works(daykey: DayKey.current())
        let names = Array(Set(all.map(\.eraLabel))).sorted()
        return names.map { era in
            (era, all.filter { $0.eraLabel == era })
        }
    }

    var body: some View {
        NavigationStack {
            List {
                Section {
                    Text("\(OxFigures.count(store.libraryCount)) paintings on this device")
                        .font(OxType.headline)
                        .foregroundStyle(OxPalette.ink)
                        .lineLimit(2)
                        .frame(maxWidth: .infinity, minHeight: OxSpace.hit, alignment: .leading)
                        .listRowBackground(OxPalette.surface)
                    Text("\(OxFigures.count(store.dueTodayCount)) words are due today")
                        .font(OxType.body)
                        .foregroundStyle(OxPalette.muted)
                        .lineLimit(2)
                        .listRowBackground(OxPalette.surface)
                } header: {
                    Text("Library")
                        .font(OxType.caption)
                        .foregroundStyle(OxPalette.muted)
                        .textCase(nil)
                }
                ForEach(sections, id: \.era) { section in
                    Section {
                        ForEach(section.works) { work in
                            row(work)
                        }
                    } header: {
                        Text(section.era)
                            .font(OxType.caption)
                            .foregroundStyle(OxPalette.muted)
                            .textCase(nil)
                    }
                }
            }
            .scrollContentBackground(.hidden)
            .background(OxPalette.background.ignoresSafeArea())
            .navigationTitle("Library")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                if showsClose {
                    ToolbarItem(placement: .cancellationAction) {
                        Button {
                            store.present(.none)
                        } label: {
                            Image(systemName: "xmark")
                                .foregroundStyle(OxPalette.ink)
                                .frame(width: OxSpace.hit, height: OxSpace.hit)
                                .contentShape(Rectangle())
                        }
                        .accessibilityLabel("Close")
                    }
                }
            }
        }
    }

    private func row(_ work: Work) -> some View {
        let saved = store.works.contains { $0.id == work.id }
        let due = store.document.memoryCards.contains { $0.workId == work.id && $0.due <= DayKey.current() }
        return VStack(alignment: .leading, spacing: OxSpace.xs) {
            Text(work.title)
                .font(OxType.headline)
                .foregroundStyle(OxPalette.ink)
                .lineLimit(2)
            Text(work.maker)
                .font(OxType.caption)
                .foregroundStyle(OxPalette.muted)
                .lineLimit(1)
            HStack(spacing: OxSpace.sm) {
                if saved {
                    Text("In crate")
                        .font(OxType.caption)
                        .foregroundStyle(OxPalette.accent)
                        .frame(minHeight: OxSpace.hit)
                } else {
                    Button("Add to today") {
                        store.saveWork(work)
                    }
                    .buttonStyle(OxTapStyle())
                    .font(OxType.headline)
                    .foregroundStyle(OxPalette.accent)
                    .frame(minHeight: OxSpace.hit)
                }
                if due {
                    Text("Due")
                        .font(OxType.caption)
                        .foregroundStyle(OxPalette.ink)
                        .frame(minHeight: OxSpace.hit)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .listRowBackground(OxPalette.surface)
    }
}
