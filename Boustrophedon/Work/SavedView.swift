import SwiftUI

/// Role: Work. Faced paintings, the crate, and reviewable YawMarks.
struct SavedView: View {
    @Bindable var store: FurrowStore
    @State private var pick: OxWorkPick?

    var body: some View {
        NavigationStack {
            Group {
                if store.works.isEmpty && store.document.yawMarks.isEmpty {
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
            .sheet(item: $pick) { item in
                OxStudySheet(store: store, workId: item.id)
                    .presentationBackground(OxPalette.surface)
                    .presentationCornerRadius(OxRadius.card)
            }
        }
    }

    private var list: some View {
        List {
            Section {
                VStack(alignment: .leading, spacing: OxSpace.sm) {
                    HStack(alignment: .firstTextBaseline, spacing: OxSpace.md) {
                        tally(OxFigures.count(store.accuracyPercent) + "%", "Accuracy")
                        tally(OxFigures.count(store.practiceStreak), "Days in a row")
                    }
                    HStack(alignment: .firstTextBaseline, spacing: OxSpace.md) {
                        tally(OxFigures.count(store.facedWorks.count), "Paintings faced")
                        tally(OxFigures.count(store.faceCount), "Words set right")
                    }
                    HStack(alignment: .firstTextBaseline, spacing: OxSpace.md) {
                        tally(OxFigures.count(store.faceCount), "Faces")
                        tally(OxFigures.count(store.yawCount), "Yaws")
                    }
                }
                .listRowBackground(OxPalette.surface)
            } header: {
                Text("Mastery")
                    .font(OxType.caption)
                    .foregroundStyle(OxPalette.muted)
                    .textCase(nil)
            }
            Section {
                ForEach(store.works) { work in
                    Button {
                        pick = OxWorkPick(id: work.id)
                    } label: {
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
                                Text(statusLine(work))
                                    .font(OxType.micro)
                                    .foregroundStyle(OxPalette.accent)
                                    .lineLimit(1)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .frame(minHeight: OxSpace.hit)
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(OxTapStyle())
                    .listRowBackground(OxPalette.surface)
                }
            } header: {
                Text("Paintings")
                    .font(OxType.caption)
                    .foregroundStyle(OxPalette.muted)
                    .textCase(nil)
            }
            if store.document.yawMarks.isEmpty == false {
                Section {
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
                } header: {
                    Text("Yaws")
                        .font(OxType.caption)
                        .foregroundStyle(OxPalette.muted)
                        .textCase(nil)
                }
            }
        }
        .scrollContentBackground(.hidden)
        .contentMargins(.bottom, OxSpace.lg, for: .scrollContent)
    }

    private func tally(_ value: String, _ label: String) -> some View {
        VStack(alignment: .leading, spacing: OxSpace.xs) {
            Text(value)
                .font(OxType.title)
                .foregroundStyle(OxPalette.ink)
                .monospacedDigit()
                .lineLimit(1)
                .layoutPriority(1)
            Text(label)
                .font(OxType.caption)
                .foregroundStyle(OxPalette.muted)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func statusLine(_ work: Work) -> String {
        if store.liveWork?.id == work.id && work.fold == .turned {
            return "On the line now"
        }
        switch work.fold {
        case .faced: return "Faced"
        case .turned: return "On the line"
        case .idle: return "Waiting"
        }
    }

    private func yawCaption(_ mark: YawMark) -> String {
        let word = OxFigures.count(mark.stichosIndex + 1)
        let day = OxFigures.daykey(mark.daykey)
        return "Word \(word) on \(day)"
    }
}

struct OxWorkPick: Identifiable, Hashable {
    var id: String
}

/// Role: Work. Dossier, private note, and a fresh line for one saved painting.
struct OxStudySheet: View {
    @Bindable var store: FurrowStore
    var workId: String
    @State private var draft = ""
    @State private var didPull = false
    @State private var routeFault = ""

    private var work: Work? {
        store.works.first { $0.id == workId }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: OxSpace.md) {
                    if let work {
                        ShelfPicture(work: work, art: "bph_OxFurrow")
                            .frame(maxWidth: .infinity)
                            .frame(height: OxSpace.band)
                            .clipShape(RoundedRectangle(cornerRadius: OxRadius.card, style: .continuous))
                        Text(work.title)
                            .font(OxType.headline)
                            .foregroundStyle(OxPalette.ink)
                            .lineLimit(2)
                        Text(work.maker)
                            .font(OxType.body)
                            .foregroundStyle(OxPalette.ink)
                            .lineLimit(2)
                        fact("Year", work.yearLabel)
                        fact("Room", work.roomLabel)
                        fact("Era", work.eraLabel)
                        fact("Inventory", work.identity)
                        if work.curatorialLine.isEmpty == false {
                            Text("Gallery note")
                                .font(OxType.caption)
                                .foregroundStyle(OxPalette.muted)
                            Text(work.curatorialLine)
                                .font(OxType.body)
                                .foregroundStyle(OxPalette.ink)
                                .lineLimit(8)
                        }
                        Text("Your note")
                            .font(OxType.caption)
                            .foregroundStyle(OxPalette.muted)
                        TextField("", text: $draft, prompt: Text("Add a private note").foregroundStyle(OxPalette.muted), axis: .vertical)
                            .foregroundStyle(OxPalette.ink)
                            .lineLimit(2...5)
                            .font(OxType.body)
                            .frame(minHeight: OxSpace.hit, alignment: .topLeading)
                        practiceButton("Practice maker", .artist, ready: work.lineReady(.artist))
                        practiceButton("Practice title", .title, ready: work.lineReady(.title))
                        practiceButton("Practice inscription", .curatorial, ready: work.lineReady(.curatorial))
                        practiceButton("Practice draft", .studio, ready: work.lineReady(.studio))
                        Button("Add to route") {
                            if store.addToRoute(workId: workId) == false {
                                routeFault = "That painting is already on the route."
                            } else {
                                routeFault = "Added to the route."
                            }
                        }
                        .buttonStyle(FaceButtonStyle(prominent: false))
                        Button("Hang this painting") {
                            _ = store.fileOntoHang(workId: workId)
                            routeFault = "Filed on a hang."
                        }
                        .buttonStyle(FaceButtonStyle(prominent: false))
                        if routeFault.isEmpty == false {
                            Text(routeFault)
                                .font(OxType.caption)
                                .foregroundStyle(OxPalette.ink)
                                .lineLimit(2)
                        }
                        StudioDrafts(store: store, workId: workId)
                    } else {
                        Text("That painting is no longer in the crate.")
                            .font(OxType.body)
                            .foregroundStyle(OxPalette.muted)
                    }
                }
                .padding(OxSpace.lg)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .background(OxPalette.background.ignoresSafeArea())
            .navigationTitle("Painting")
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
            .onAppear { pull() }
            .onChange(of: draft) { _, value in
                guard didPull else { return }
                store.updateNote(id: workId, note: value)
            }
        }
    }

    private func practiceButton(_ title: String, _ field: FurrowField, ready: Bool) -> some View {
        Button(title) {
            if store.reopenForPractice(id: workId, field: field) {
                store.present(.none)
            }
        }
        .buttonStyle(FaceButtonStyle(prominent: ready))
        .disabled(ready == false)
    }

    @ViewBuilder
    private func fact(_ label: String, _ value: String) -> some View {
        if value.isEmpty == false {
            HStack(alignment: .firstTextBaseline, spacing: OxSpace.sm) {
                Text(label)
                    .font(OxType.caption)
                    .foregroundStyle(OxPalette.muted)
                    .frame(width: OxSpace.lg * 3, alignment: .leading)
                Text(value)
                    .font(OxType.body)
                    .foregroundStyle(OxPalette.ink)
                    .lineLimit(2)
            }
        }
    }

    private func pull() {
        guard didPull == false else { return }
        didPull = true
        draft = work?.userNote ?? ""
    }
}
