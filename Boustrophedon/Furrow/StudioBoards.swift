import SwiftUI

/// Role: Furrow. Read the open line the way the ox walks. Odd rows sit on the right.
struct PloughBoard: View {
    @Bindable var store: FurrowStore
    @State private var fault = ""
    @State private var finishedPulse = 0

    var body: some View {
        VStack(alignment: .leading, spacing: OxSpace.sm) {
            Text("Read with the ox")
                .font(OxType.headline)
                .foregroundStyle(OxPalette.ink)
                .lineLimit(1)
            Text("First row left to right. The next row comes back from the right.")
                .font(OxType.caption)
                .foregroundStyle(OxPalette.muted)
                .lineLimit(2)
            if let course = store.document.livePlough {
                rows(course)
            } else if fault == "The ox finished this line." {
                Text(fault)
                    .font(OxType.body)
                    .foregroundStyle(OxPalette.ink)
                    .lineLimit(2)
            } else {
                Text("This line is waiting for a cut.")
                    .font(OxType.body)
                    .foregroundStyle(OxPalette.ink)
                    .lineLimit(2)
            }
            if fault.isEmpty == false, store.document.livePlough != nil {
                Text(fault)
                    .font(OxType.caption)
                    .foregroundStyle(OxPalette.ink)
                    .lineLimit(2)
            }
            if let course = store.document.livePlough, course.misses > 0 {
                Text("Misses \(OxFigures.count(course.misses))")
                    .font(OxType.micro)
                    .foregroundStyle(OxPalette.muted)
                    .monospacedDigit()
                    .lineLimit(1)
            }
            if store.document.livePlough == nil {
                Button("Cut a plough") {
                    fault = ""
                    if store.openPlough() == false {
                        fault = "This line is too short to plough."
                    }
                }
                .buttonStyle(FaceButtonStyle())
            } else {
                Button("Start this line over") {
                    fault = ""
                    if store.restartPlough() == false {
                        fault = "This line is too short to plough."
                    }
                }
                .buttonStyle(FaceButtonStyle(prominent: false))
            }
        }
        .padding(OxSpace.sm)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: OxRadius.card, style: .continuous)
                .fill(OxPalette.surface)
        )
        .sensoryFeedback(.success, trigger: finishedPulse)
    }

    private func rows(_ course: PloughCourse) -> some View {
        let grouped = Dictionary(grouping: course.cells, by: \.row)
        let keys = grouped.keys.sorted()
        return VStack(alignment: .leading, spacing: OxSpace.xs) {
            ForEach(keys, id: \.self) { key in
                let cells = grouped[key, default: []].sorted { $0.visualSlot < $1.visualSlot }
                HStack(spacing: OxSpace.xs) {
                    if key % 2 == 1 { Spacer(minLength: 0) }
                    ForEach(cells) { cell in
                        cellButton(cell, course: course)
                    }
                    if key % 2 == 0 { Spacer(minLength: 0) }
                }
            }
        }
    }

    private func cellButton(_ cell: PloughCell, course: PloughCourse) -> some View {
        let done = cell.tokenIndex < course.nextToken
        let next = cell.tokenIndex == course.nextToken
        return Button {
            let ok = store.tapPlough(tokenIndex: cell.tokenIndex)
            if ok, store.document.livePlough == nil {
                fault = "The ox finished this line."
                finishedPulse += 1
            } else if ok {
                fault = ""
            } else {
                fault = "Stay on the word the ox is reading."
            }
        } label: {
            VStack(spacing: 0) {
                Text(cell.word)
                    .font(next ? OxType.headline : OxType.body)
                    .foregroundStyle(next ? OxPalette.accent : (done ? OxPalette.ink : OxPalette.muted))
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                Text(done ? "Read" : (next ? "Next" : "Later"))
                    .font(OxType.micro)
                    .foregroundStyle(next ? OxPalette.accent : OxPalette.muted)
                    .lineLimit(1)
            }
            .padding(.horizontal, OxSpace.xs)
            .frame(minWidth: 0, maxWidth: .infinity, minHeight: OxSpace.hit)
            .background(
                RoundedRectangle(cornerRadius: OxRadius.chip, style: .continuous)
                    .fill(next ? OxPalette.accent.opacity(0.14) : OxPalette.background)
            )
            .contentShape(RoundedRectangle(cornerRadius: OxRadius.chip, style: .continuous))
        }
        .buttonStyle(OxTapStyle())
        .disabled(done)
        .accessibilityLabel("\(cell.word), \(done ? "read" : (next ? "next" : "later"))")
    }
}

/// Role: Furrow. Spell one backward word forward, letter by letter.
struct BenchBoard: View {
    @Bindable var store: FurrowStore
    @State private var fault = ""
    @State private var solvedPulse = 0

    var body: some View {
        VStack(alignment: .leading, spacing: OxSpace.sm) {
            Text("Spell it forward")
                .font(OxType.headline)
                .foregroundStyle(OxPalette.ink)
                .lineLimit(1)
            if let course = store.document.liveBench {
                Text(course.retrograde)
                    .font(OxType.title)
                    .foregroundStyle(OxPalette.accent)
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
                    .frame(maxWidth: .infinity, alignment: .leading)
                slots(course)
                OxFlowLayout(spacing: OxSpace.xs) {
                    ForEach(course.tray) { tile in
                        Button {
                            if store.placeBench(tileId: tile.id) {
                                if store.document.liveBench == nil {
                                    fault = "That word now reads forward."
                                    solvedPulse += 1
                                } else {
                                    fault = ""
                                }
                            } else {
                                fault = "Not that letter."
                            }
                        } label: {
                            Text(tile.letter)
                                .font(OxType.headline)
                                .foregroundStyle(OxPalette.ink)
                                .frame(minWidth: OxSpace.hit, minHeight: OxSpace.hit)
                                .background(
                                    RoundedRectangle(cornerRadius: OxRadius.chip, style: .continuous)
                                        .fill(OxPalette.background)
                                )
                                .contentShape(RoundedRectangle(cornerRadius: OxRadius.chip, style: .continuous))
                        }
                        .buttonStyle(OxTapStyle())
                        .accessibilityLabel("Letter \(tile.letter)")
                    }
                }
                if course.misses > 0 {
                    Text("Misses \(OxFigures.count(course.misses))")
                        .font(OxType.micro)
                        .foregroundStyle(OxPalette.muted)
                        .monospacedDigit()
                        .lineLimit(1)
                }
                Button("Undo letter") { store.undoBench() }
                    .buttonStyle(FaceButtonStyle(prominent: false))
                    .disabled(course.placed.isEmpty)
            } else {
                Text(fault.isEmpty ? "No backward word is waiting on this line." : fault)
                    .font(OxType.body)
                    .foregroundStyle(OxPalette.ink)
                    .lineLimit(3)
                Button("Lay the bench") {
                    fault = ""
                    if store.openBench() == false {
                        fault = "No backward word is waiting on this line."
                    }
                }
                .buttonStyle(FaceButtonStyle())
            }
            if fault.isEmpty == false, store.document.liveBench != nil {
                Text(fault)
                    .font(OxType.caption)
                    .foregroundStyle(OxPalette.ink)
                    .lineLimit(2)
            }
        }
        .padding(OxSpace.sm)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: OxRadius.card, style: .continuous)
                .fill(OxPalette.surface)
        )
        .sensoryFeedback(.success, trigger: solvedPulse)
    }

    private func slots(_ course: BenchCourse) -> some View {
        let total = Array(course.catalog).count
        return OxFlowLayout(spacing: OxSpace.xs) {
            ForEach(0..<total, id: \.self) { index in
                let letter = index < course.placed.count ? course.placed[index] : ""
                Text(letter.isEmpty ? " " : letter)
                    .font(OxType.headline)
                    .foregroundStyle(OxPalette.ink)
                    .frame(minWidth: OxSpace.hit, minHeight: OxSpace.hit)
                    .background(
                        RoundedRectangle(cornerRadius: OxRadius.chip, style: .continuous)
                            .fill(OxPalette.background)
                    )
                    .accessibilityLabel(letter.isEmpty ? "Empty slot" : letter)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

/// Role: Furrow. Captions the reader wrote, then turned into a live line.
struct StudioDrafts: View {
    @Bindable var store: FurrowStore
    var workId: String
    @State private var title = ""
    @State private var bodyText = ""
    @State private var fault = ""

    private var drafts: [CaptionDraft] {
        store.document.drafts.filter { $0.workId == workId }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: OxSpace.sm) {
            Text("Your captions")
                .font(OxType.headline)
                .foregroundStyle(OxPalette.ink)
                .lineLimit(1)
            TextField("Name", text: $title)
                .font(OxType.body)
                .foregroundStyle(OxPalette.ink)
                .frame(minHeight: OxSpace.hit)
            TextField("Two words or more", text: $bodyText, axis: .vertical)
                .lineLimit(2...4)
                .font(OxType.body)
                .foregroundStyle(OxPalette.ink)
                .frame(minHeight: OxSpace.hit, alignment: .topLeading)
            if fault.isEmpty == false {
                Text(fault)
                    .font(OxType.caption)
                    .foregroundStyle(OxPalette.ink)
                    .lineLimit(2)
            }
            Button("Save caption") { save() }
                .buttonStyle(FaceButtonStyle())
            ForEach(drafts) { draft in
                VStack(alignment: .leading, spacing: OxSpace.xs) {
                    Text(draft.title)
                        .font(OxType.headline)
                        .foregroundStyle(OxPalette.ink)
                        .lineLimit(1)
                    Text(draft.body)
                        .font(OxType.body)
                        .foregroundStyle(OxPalette.muted)
                        .lineLimit(3)
                    HStack(spacing: OxSpace.sm) {
                        Button("Turn") {
                            if store.turnDraft(id: draft.id) {
                                store.present(.none)
                            }
                        }
                        .buttonStyle(OxTapStyle())
                        .font(OxType.headline)
                        .foregroundStyle(OxPalette.accent)
                        .frame(minHeight: OxSpace.hit)
                        Button("Delete") { store.deleteDraft(id: draft.id) }
                            .buttonStyle(OxTapStyle())
                            .font(OxType.headline)
                            .foregroundStyle(OxPalette.ink)
                            .frame(minHeight: OxSpace.hit)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .padding(OxSpace.sm)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: OxRadius.card, style: .continuous)
                .fill(OxPalette.surface)
        )
    }

    private func save() {
        if store.saveDraft(workId: workId, title: title, body: bodyText) {
            title = ""
            bodyText = ""
            fault = ""
        } else {
            fault = "Use at least two words."
        }
    }
}
