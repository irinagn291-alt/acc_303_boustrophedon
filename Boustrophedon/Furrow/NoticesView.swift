import SwiftUI

/// Role: Furrow. The reader writes what they see. The gallery label stays off this card.
struct NoticeCard: View {
    @Bindable var store: FurrowStore
    @State private var light = ""
    @State private var thing = ""
    @State private var word = ""
    @State private var fault = ""
    @State private var seenId = ""

    var body: some View {
        VStack(alignment: .leading, spacing: OxSpace.sm) {
            HStack(alignment: .firstTextBaseline) {
                Text("What you notice")
                    .font(OxType.headline)
                    .foregroundStyle(OxPalette.ink)
                    .lineLimit(1)
                    .frame(maxWidth: .infinity, alignment: .leading)
                Button("All notices") { store.present(.notices) }
                    .buttonStyle(OxTapStyle())
                    .font(OxType.caption)
                    .foregroundStyle(OxPalette.accent)
                    .frame(minHeight: OxSpace.hit)
            }
            Text("Your words. The gallery caption stays out of this.")
                .font(OxType.caption)
                .foregroundStyle(OxPalette.muted)
                .lineLimit(2)
            field("The light", text: $light)
            field("One thing you can point at", text: $thing)
            field("A word that fits", text: $word)
            if fault.isEmpty == false {
                Text(fault)
                    .font(OxType.caption)
                    .foregroundStyle(OxPalette.ink)
                    .lineLimit(2)
            }
            Button("Keep notice") { save() }
                .buttonStyle(FaceButtonStyle())
        }
        .padding(OxSpace.sm)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: OxRadius.card, style: .continuous)
                .fill(OxPalette.surface)
        )
        .onAppear { pull() }
        .onChange(of: store.liveWork?.id) { _, _ in pull() }
    }

    private func field(_ title: String, text: Binding<String>) -> some View {
        TextField("", text: text, prompt: Text(title).foregroundStyle(OxPalette.muted), axis: .vertical)
            .lineLimit(1...3)
            .font(OxType.body)
            .foregroundStyle(OxPalette.ink)
            .frame(minHeight: OxSpace.hit, alignment: .topLeading)
    }

    private func save() {
        guard let id = store.liveWork?.id else { return }
        if store.saveNotice(workId: id, light: light, thing: thing, word: word) {
            fault = ""
        } else {
            fault = "Use at least two words in one of the lines."
        }
    }

    private func pull() {
        let id = store.liveWork?.id ?? ""
        guard id != seenId else { return }
        seenId = id
        let note = store.document.notices.first { $0.id == id }
        light = note?.light ?? ""
        thing = note?.thing ?? ""
        word = note?.word ?? ""
        fault = ""
    }
}

/// Role: Furrow. Every notice the reader has kept.
struct NoticesView: View {
    @Bindable var store: FurrowStore
    var showsClose: Bool = true

    var body: some View {
        NavigationStack {
            Group {
                if store.document.notices.isEmpty {
                    QuietPage(
                        art: "bph_EmptyList",
                        headline: "Nothing noticed yet.",
                        line: "Look at the painting and write the light, one thing, and a word that fits.",
                        actionTitle: "Back to the line"
                    ) {
                        store.present(.none)
                    }
                } else {
                    list
                }
            }
            .background(OxPalette.background.ignoresSafeArea())
            .navigationTitle("Notices")
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

    private var list: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: OxSpace.md) {
                ForEach(store.document.notices) { note in
                    let work = store.works.first { $0.id == note.id }
                    VStack(alignment: .leading, spacing: OxSpace.xs) {
                        Text(work?.title ?? "Painting")
                            .font(OxType.headline)
                            .foregroundStyle(OxPalette.ink)
                            .lineLimit(2)
                        noticeLine("Light", note.light)
                        noticeLine("Thing", note.thing)
                        noticeLine("Word", note.word)
                    }
                    .padding(OxSpace.sm)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(
                        RoundedRectangle(cornerRadius: OxRadius.card, style: .continuous)
                            .fill(OxPalette.surface)
                    )
                }
            }
            .padding(OxSpace.lg)
        }
    }

    @ViewBuilder
    private func noticeLine(_ label: String, _ value: String) -> some View {
        if value.isEmpty == false {
            HStack(alignment: .firstTextBaseline, spacing: OxSpace.sm) {
                Text(label)
                    .font(OxType.caption)
                    .foregroundStyle(OxPalette.muted)
                    .lineLimit(1)
                    .frame(width: OxSpace.lg * 2, alignment: .leading)
                Text(value)
                    .font(OxType.body)
                    .foregroundStyle(OxPalette.ink)
                    .lineLimit(3)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }
}
