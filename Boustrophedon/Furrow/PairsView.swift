import SwiftUI

/// Role: Furrow. A written comparison of two saved paintings.
struct PairsView: View {
    @Bindable var store: FurrowStore
    var showsClose: Bool = true
    @State private var left = ""
    @State private var right = ""
    @State private var bodyText = ""
    @State private var fault = ""

    var body: some View {
        NavigationStack {
            Group {
                if store.works.count < 2 && store.document.pairNotes.isEmpty {
                    QuietPage(
                        art: "bph_EmptyList",
                        headline: "A pair needs two.",
                        line: "Save a second painting, then write what they share.",
                        actionTitle: "Back to the line"
                    ) {
                        store.present(.none)
                    }
                } else {
                    list
                }
            }
            .background(OxPalette.background.ignoresSafeArea())
            .navigationTitle("Pairs")
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
            .onAppear { seedPicks() }
        }
    }

    private var list: some View {
        List {
            if store.works.count >= 2 {
                Section("New pair") {
                    Picker("Left", selection: $left) {
                        ForEach(store.works) { work in
                            Text(work.title).tag(work.id)
                        }
                    }
                    .listRowBackground(OxPalette.surface)
                    Picker("Right", selection: $right) {
                        ForEach(store.works) { work in
                            Text(work.title).tag(work.id)
                        }
                    }
                    .listRowBackground(OxPalette.surface)
                    TextField("What they share", text: $bodyText, axis: .vertical)
                        .lineLimit(2...4)
                        .font(OxType.body)
                        .foregroundStyle(OxPalette.ink)
                        .listRowBackground(OxPalette.surface)
                    if fault.isEmpty == false {
                        Text(fault)
                            .font(OxType.caption)
                            .foregroundStyle(OxPalette.ink)
                            .listRowBackground(OxPalette.surface)
                    }
                    Button("Save pair") { save() }
                        .buttonStyle(FaceButtonStyle())
                        .listRowBackground(OxPalette.background)
                }
            }
            Section("Saved pairs") {
                if store.document.pairNotes.isEmpty {
                    Text("No pair yet.")
                        .font(OxType.body)
                        .foregroundStyle(OxPalette.muted)
                        .frame(minHeight: OxSpace.hit, alignment: .leading)
                        .listRowBackground(OxPalette.surface)
                } else {
                    ForEach(store.document.pairNotes) { pair in
                        VStack(alignment: .leading, spacing: OxSpace.xs) {
                            Text(pairTitle(pair))
                                .font(OxType.headline)
                                .foregroundStyle(OxPalette.ink)
                                .lineLimit(2)
                            Text(pair.body)
                                .font(OxType.body)
                                .foregroundStyle(OxPalette.muted)
                                .lineLimit(4)
                            Button("Delete") { store.deletePair(id: pair.id) }
                                .buttonStyle(OxTapStyle())
                                .font(OxType.headline)
                                .foregroundStyle(OxPalette.ink)
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

    private func pairTitle(_ pair: PairNote) -> String {
        let leftTitle = store.works.first { $0.id == pair.leftId }?.title ?? "Painting"
        let rightTitle = store.works.first { $0.id == pair.rightId }?.title ?? "Painting"
        return "\(leftTitle) and \(rightTitle)"
    }

    private func seedPicks() {
        guard left.isEmpty, let first = store.works.first else { return }
        left = first.id
        right = store.works.dropFirst().first?.id ?? first.id
    }

    private func save() {
        if store.savePair(leftId: left, rightId: right, body: bodyText) {
            bodyText = ""
            fault = ""
        } else if left == right {
            fault = "Choose two different paintings."
        } else {
            fault = "Use at least two words."
        }
    }
}
