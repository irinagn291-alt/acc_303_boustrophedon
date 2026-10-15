import SwiftUI

/// Role: Furrow. Walk the crate by room. Each room keeps a note and a minute count.
struct RoomsView: View {
    @Bindable var store: FurrowStore
    var showsClose: Bool = true

    var body: some View {
        NavigationStack {
            Group {
                if store.roomRows.isEmpty {
                    QuietPage(
                        art: "bph_EmptyList",
                        headline: "No rooms yet.",
                        line: "Save a painting that names its room, then walk it.",
                        actionTitle: "Back to the line"
                    ) {
                        store.present(.none)
                    }
                } else {
                    list
                }
            }
            .background(OxPalette.background.ignoresSafeArea())
            .navigationTitle("Rooms")
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
            .navigationDestination(for: String.self) { title in
                RoomDetailView(store: store, title: title)
            }
        }
    }

    private var list: some View {
        List {
            Section {
                Text("\(OxFigures.count(store.roomsWalked)) of \(OxFigures.count(store.roomRows.count)) walked")
                    .font(OxType.headline)
                    .foregroundStyle(OxPalette.ink)
                    .monospacedDigit()
                    .frame(maxWidth: .infinity, minHeight: OxSpace.hit, alignment: .leading)
                    .listRowBackground(OxPalette.surface)
            }
            Section("Rooms") {
                ForEach(store.roomRows) { room in
                    NavigationLink(value: room.title) {
                        VStack(alignment: .leading, spacing: OxSpace.xs) {
                            Text(room.title)
                                .font(OxType.headline)
                                .foregroundStyle(OxPalette.ink)
                                .lineLimit(1)
                            Text(summary(room))
                                .font(OxType.caption)
                                .foregroundStyle(OxPalette.muted)
                                .lineLimit(2)
                        }
                        .frame(maxWidth: .infinity, minHeight: OxSpace.hit, alignment: .leading)
                    }
                    .listRowBackground(OxPalette.surface)
                }
            }
        }
        .scrollContentBackground(.hidden)
        .contentMargins(.bottom, OxSpace.lg, for: .scrollContent)
    }

    private func summary(_ room: RoomRow) -> String {
        let count = OxFigures.count(room.workIds.count)
        let minutes = OxFigures.count(room.minutes)
        let state = room.walked ? "Walked" : "Still to walk"
        return "\(state). \(count) paintings. \(minutes) min"
    }
}

/// Role: Furrow. One room. Note, minutes, and the paintings that hang there.
struct RoomDetailView: View {
    @Bindable var store: FurrowStore
    var title: String
    @State private var note = ""
    @State private var didPull = false

    private var room: RoomRow? {
        store.roomRows.first { $0.title == title }
    }

    var body: some View {
        List {
            Section(title) {
                Text(room?.walked == true ? "Walked" : "Still to walk")
                    .font(OxType.headline)
                    .foregroundStyle(OxPalette.ink)
                    .frame(minHeight: OxSpace.hit, alignment: .leading)
                    .listRowBackground(OxPalette.surface)
                HStack(spacing: OxSpace.sm) {
                    Button("Less") { store.shiftRoomMinutes(title: title, delta: -5) }
                    Text("\(OxFigures.count(room?.minutes ?? 0)) min")
                        .font(OxType.headline)
                        .foregroundStyle(OxPalette.ink)
                        .monospacedDigit()
                        .frame(maxWidth: .infinity)
                    Button("More") { store.shiftRoomMinutes(title: title, delta: 5) }
                }
                .buttonStyle(OxTapStyle())
                .font(OxType.headline)
                .foregroundStyle(OxPalette.ink)
                .frame(minHeight: OxSpace.hit)
                .listRowBackground(OxPalette.surface)
                TextField("What this room is for", text: $note, axis: .vertical)
                    .lineLimit(2...4)
                    .font(OxType.body)
                    .foregroundStyle(OxPalette.ink)
                    .listRowBackground(OxPalette.surface)
                Button(room?.walked == true ? "Mark still to walk" : "Mark walked") {
                    store.setRoomWalked(title: title, walked: room?.walked != true)
                }
                .frame(minHeight: OxSpace.hit)
                .listRowBackground(OxPalette.surface)
            }
            Section("Paintings") {
                ForEach(room?.workIds ?? [], id: \.self) { workId in
                    let work = store.works.first { $0.id == workId }
                    VStack(alignment: .leading, spacing: OxSpace.xs) {
                        Text(work?.title ?? "Painting")
                            .font(OxType.headline)
                            .foregroundStyle(OxPalette.ink)
                            .lineLimit(1)
                        Text(work?.maker ?? " ")
                            .font(OxType.caption)
                            .foregroundStyle(OxPalette.muted)
                            .lineLimit(1)
                    }
                    .frame(maxWidth: .infinity, minHeight: OxSpace.hit, alignment: .leading)
                    .listRowBackground(OxPalette.surface)
                }
            }
        }
        .scrollContentBackground(.hidden)
        .background(OxPalette.background.ignoresSafeArea())
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear { pull() }
        .onChange(of: note) { _, value in
            guard didPull else { return }
            store.updateRoomNote(title: title, note: value)
        }
    }

    private func pull() {
        guard didPull == false else { return }
        didPull = true
        note = room?.note ?? ""
    }
}
