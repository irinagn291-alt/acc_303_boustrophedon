import SwiftUI

/// Role: Furrow. The word book. Every faced or yawed token, searchable on this device.
struct LexiconView: View {
    @Bindable var store: FurrowStore
    var showsClose: Bool = true
    @State private var query = ""
    @State private var cut: LexiconCut = .all

    private var rows: [Lexeme] {
        let needle = query.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        return store.document.lexemes
            .filter { lexeme in
                let cutMatches: Bool
                switch cut {
                case .all:
                    cutMatches = true
                case .rough:
                    cutMatches = lexeme.yawCount > lexeme.faceCount
                case .pinned:
                    cutMatches = lexeme.pinned
                }
                guard cutMatches else { return false }
                guard needle.isEmpty == false else { return true }
                if lexeme.catalog.lowercased().contains(needle) { return true }
                if lexeme.retrograde.lowercased().contains(needle) { return true }
                return lexeme.workIds.contains { id in
                    guard let work = store.works.first(where: { $0.id == id }) else { return false }
                    return work.title.lowercased().contains(needle) || work.maker.lowercased().contains(needle)
                }
            }
            .sorted { $0.catalog.localizedCaseInsensitiveCompare($1.catalog) == .orderedAscending }
    }

    var body: some View {
        NavigationStack {
            Group {
                if store.document.lexemes.isEmpty {
                    QuietPage(
                        art: "bph_EmptyList",
                        headline: "The book is empty.",
                        line: "Face a backward word and it lands here, with the spelling turned around.",
                        actionTitle: "Back to the line"
                    ) {
                        store.present(.none)
                    }
                } else {
                    list
                }
            }
            .background(OxPalette.background.ignoresSafeArea())
            .navigationTitle("Word book")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                if showsClose {
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
    }

    private var list: some View {
        List {
            Section {
                TextField("", text: $query, prompt: Text("Search words or paintings").foregroundStyle(OxPalette.muted))
                    .font(OxType.body)
                    .foregroundStyle(OxPalette.ink)
                    .frame(minHeight: OxSpace.hit)
                    .listRowBackground(OxPalette.surface)
                Picker("Cut", selection: $cut) {
                    ForEach(LexiconCut.allCases) { item in
                        Text(item.title).tag(item)
                    }
                }
                .pickerStyle(.segmented)
                .listRowBackground(OxPalette.surface)
            }
            if rows.isEmpty {
                Section {
                    Text("Nothing in this cut.")
                        .font(OxType.body)
                        .foregroundStyle(OxPalette.muted)
                        .frame(maxWidth: .infinity, minHeight: OxSpace.hit, alignment: .leading)
                        .listRowBackground(OxPalette.surface)
                }
            } else {
                Section("\(OxFigures.count(rows.count)) words") {
                    ForEach(rows) { lexeme in
                        VStack(alignment: .leading, spacing: OxSpace.xs) {
                            HStack(alignment: .firstTextBaseline, spacing: OxSpace.sm) {
                                Text(lexeme.catalog)
                                    .font(OxType.headline)
                                    .foregroundStyle(OxPalette.ink)
                                    .lineLimit(1)
                                Text(lexeme.retrograde)
                                    .font(OxType.body)
                                    .foregroundStyle(OxPalette.accent)
                                    .lineLimit(1)
                                Spacer(minLength: OxSpace.xs)
                                Button(lexeme.pinned ? "Unpin" : "Pin") {
                                    store.setLexemePinned(id: lexeme.id, pinned: lexeme.pinned == false)
                                }
                                .buttonStyle(OxTapStyle())
                                .font(OxType.caption)
                                .foregroundStyle(OxPalette.ink)
                                .frame(minHeight: OxSpace.hit)
                            }
                            Text(detail(lexeme))
                                .font(OxType.caption)
                                .foregroundStyle(OxPalette.muted)
                                .lineLimit(2)
                            Button("Practice") { store.practiceLexeme(id: lexeme.id) }
                                .buttonStyle(OxTapStyle())
                                .font(OxType.headline)
                                .foregroundStyle(OxPalette.accent)
                                .frame(minHeight: OxSpace.hit)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .listRowBackground(OxPalette.surface)
                    }
                }
            }
        }
        .scrollContentBackground(.hidden)
        .contentMargins(.bottom, OxSpace.lg, for: .scrollContent)
    }

    private func detail(_ lexeme: Lexeme) -> String {
        let faces = OxFigures.count(lexeme.faceCount)
        let yaws = OxFigures.count(lexeme.yawCount)
        let title = lexeme.workIds.compactMap { id in
            store.works.first { $0.id == id }?.title
        }.first ?? "Saved painting"
        return "\(faces) faced, \(yaws) yaws. \(title)"
    }
}

private enum LexiconCut: String, CaseIterable, Identifiable {
    case all
    case rough
    case pinned

    var id: String { rawValue }

    var title: String {
        switch self {
        case .all: "All"
        case .rough: "Rough"
        case .pinned: "Pinned"
        }
    }
}
