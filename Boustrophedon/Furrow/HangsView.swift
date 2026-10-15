import SwiftUI

/// Role: Furrow. Named walls. Paintings stay in the order the reader walks them.
struct HangsView: View {
    @Bindable var store: FurrowStore
    var showsClose: Bool = true
    @State private var name = ""
    @State private var fault = ""

    var body: some View {
        NavigationStack {
            Group {
                if store.document.hangs.isEmpty {
                    empty
                } else {
                    list
                }
            }
            .background(OxPalette.background.ignoresSafeArea())
            .navigationTitle("Hangs")
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
            .navigationDestination(for: String.self) { hangId in
                HangDetailView(store: store, hangId: hangId)
            }
        }
    }

    private var empty: some View {
        VStack(alignment: .leading, spacing: OxSpace.md) {
            Spacer(minLength: OxSpace.lg)
            Image("bph_EmptyList")
                .resizable()
                .scaledToFit()
                .frame(maxWidth: OxSpace.lg * 7, maxHeight: OxSpace.lg * 7)
                .accessibilityHidden(true)
            Text("No hang yet.")
                .font(OxType.display(.large))
                .foregroundStyle(OxPalette.ink)
                .lineLimit(2)
            Text("Name a wall, then add paintings from the open line or from Saved.")
                .font(OxType.body)
                .foregroundStyle(OxPalette.muted)
                .lineLimit(3)
            TextField("Wall name", text: $name)
                .font(OxType.body)
                .foregroundStyle(OxPalette.ink)
                .frame(minHeight: OxSpace.hit)
            if fault.isEmpty == false {
                Text(fault)
                    .font(OxType.caption)
                    .foregroundStyle(OxPalette.ink)
                    .lineLimit(2)
            }
            Spacer(minLength: OxSpace.lg)
            Button("Save hang") { create() }
                .buttonStyle(FaceButtonStyle())
        }
        .padding(OxSpace.lg)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
    }

    private var list: some View {
        List {
            Section {
                TextField("Wall name", text: $name)
                    .font(OxType.body)
                    .foregroundStyle(OxPalette.ink)
                    .frame(minHeight: OxSpace.hit)
                    .listRowBackground(OxPalette.surface)
                if fault.isEmpty == false {
                    Text(fault)
                        .font(OxType.caption)
                        .foregroundStyle(OxPalette.ink)
                        .listRowBackground(OxPalette.surface)
                }
                Button("Save hang") { create() }
                    .buttonStyle(FaceButtonStyle())
                    .listRowBackground(OxPalette.background)
            }
            Section("Walls") {
                ForEach(store.document.hangs) { hang in
                    NavigationLink(value: hang.id) {
                        VStack(alignment: .leading, spacing: OxSpace.xs) {
                            Text(hang.title)
                                .font(OxType.headline)
                                .foregroundStyle(OxPalette.ink)
                                .lineLimit(1)
                            Text(summary(hang))
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

    private func summary(_ hang: Hang) -> String {
        let count = OxFigures.count(hang.workIds.count)
        if hang.note.isEmpty { return "\(count) paintings" }
        return "\(count) paintings. \(hang.note)"
    }

    private func create() {
        if store.createHang(title: name) != nil {
            name = ""
            fault = ""
        } else {
            fault = "Name the wall first."
        }
    }
}

/// Role: Furrow. One wall. Order, a note, and the paintings on it.
struct HangDetailView: View {
    @Bindable var store: FurrowStore
    var hangId: String
    @State private var title = ""
    @State private var note = ""
    @State private var didPull = false
    @State private var confirmDelete = false

    private var hang: Hang? {
        store.document.hangs.first { $0.id == hangId }
    }

    var body: some View {
        Group {
            if hang == nil {
                Text("That hang is gone.")
                    .font(OxType.body)
                    .foregroundStyle(OxPalette.muted)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                    .padding(OxSpace.lg)
            } else {
                list
            }
        }
        .background(OxPalette.background.ignoresSafeArea())
        .navigationTitle(hang?.title ?? "Hang")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear { pull() }
        .confirmationDialog("Remove this hang from the device?", isPresented: $confirmDelete, titleVisibility: .visible) {
            Button("Delete hang", role: .destructive) { store.deleteHang(id: hangId) }
            Button("Keep", role: .cancel) {}
        }
    }

    private var list: some View {
        List {
            Section("Wall") {
                TextField("Name", text: $title)
                    .font(OxType.body)
                    .foregroundStyle(OxPalette.ink)
                    .frame(minHeight: OxSpace.hit)
                    .listRowBackground(OxPalette.surface)
                TextField("Note for this wall", text: $note, axis: .vertical)
                    .lineLimit(2...4)
                    .font(OxType.body)
                    .foregroundStyle(OxPalette.ink)
                    .listRowBackground(OxPalette.surface)
                Button("Add the open painting") { addOpen() }
                    .frame(minHeight: OxSpace.hit)
                    .listRowBackground(OxPalette.surface)
            }
            Section("Walk") {
                if hang?.workIds.isEmpty ?? true {
                    Text("This wall is still bare.")
                        .font(OxType.body)
                        .foregroundStyle(OxPalette.muted)
                        .frame(minHeight: OxSpace.hit, alignment: .leading)
                        .listRowBackground(OxPalette.surface)
                } else {
                    ForEach(hang?.workIds ?? [], id: \.self) { workId in
                        workRow(workId)
                    }
                }
            }
            Section {
                Button("Delete hang", role: .destructive) { confirmDelete = true }
                    .buttonStyle(FaceButtonStyle(isDestructive: true))
                    .listRowBackground(OxPalette.background)
            }
        }
        .scrollContentBackground(.hidden)
        .onChange(of: title) { _, value in
            guard didPull else { return }
            store.renameHang(id: hangId, title: value)
        }
        .onChange(of: note) { _, value in
            guard didPull else { return }
            store.updateHangNote(id: hangId, note: value)
        }
    }

    private func workRow(_ workId: String) -> some View {
        let work = store.works.first { $0.id == workId }
        return VStack(alignment: .leading, spacing: OxSpace.xs) {
            Text(work?.title ?? "Missing painting")
                .font(OxType.headline)
                .foregroundStyle(OxPalette.ink)
                .lineLimit(1)
            Text(work?.maker ?? " ")
                .font(OxType.caption)
                .foregroundStyle(OxPalette.muted)
                .lineLimit(1)
            HStack(spacing: OxSpace.sm) {
                Button("Up") { store.moveHangWork(hangId: hangId, workId: workId, direction: -1) }
                Button("Down") { store.moveHangWork(hangId: hangId, workId: workId, direction: 1) }
                Button("Remove") { store.removeWork(workId, fromHang: hangId) }
            }
            .buttonStyle(OxTapStyle())
            .font(OxType.caption)
            .foregroundStyle(OxPalette.ink)
            .frame(minHeight: OxSpace.hit)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .listRowBackground(OxPalette.surface)
    }

    private func addOpen() {
        guard let id = store.liveWork?.id else { return }
        store.addWork(id, toHang: hangId)
    }

    private func pull() {
        guard didPull == false, let hang else { return }
        title = hang.title
        note = hang.note
        didPull = true
    }
}
