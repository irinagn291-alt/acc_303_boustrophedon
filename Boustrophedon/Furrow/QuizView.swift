import SwiftUI

/// Role: Furrow. Locked ox-plough line. Turn and Face fuse here. Sheets leave the furrow in place.
struct QuizView: View {
    @Bindable var store: FurrowStore
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.dynamicTypeSize) private var typeSize
    @Environment(\.horizontalSizeClass) private var sizeClass
    @State private var facePulse = 0
    @State private var praise = false
    @State private var note = ""
    @State private var scopeNote = ""
    @State private var showLetters = false

    private var wide: Bool { sizeClass == .regular }

    var body: some View {
        Group {
            if store.works.isEmpty {
                QuietPage(
                    art: "bph_EmptyHome",
                    headline: "Crate level.",
                    line: "Save a work, then face.",
                    actionTitle: "Explore"
                ) {
                    store.present(.explore)
                }
            } else if store.turnableWorks.isEmpty {
                settled
            } else {
                furrow
            }
        }
        .background(OxPalette.background.ignoresSafeArea())
        .sensoryFeedback(.success, trigger: facePulse)
        .sheet(isPresented: $showLetters) {
            OxLetterSheet(
                stichoi: store.liveFurrow?.stichoi ?? [],
                blind: store.document.drillBlind
            ) {
                showLetters = false
            }
            .presentationBackground(OxPalette.surface)
            .presentationCornerRadius(OxRadius.card)
        }
    }

    private var furrow: some View {
        VStack(spacing: 0) {
            chrome
                .padding(.horizontal, OxSpace.lg)
                .padding(.top, OxSpace.sm)
                .padding(.bottom, OxSpace.sm)
            if wide {
                HStack(alignment: .top, spacing: OxSpace.lg) {
                    ScrollView { paintingColumn }
                    ScrollView { playColumn }
                        .frame(maxWidth: OxSpace.band + OxSpace.xl * 4)
                }
                .padding(.horizontal, OxSpace.lg)
            } else {
                ScrollView {
                    VStack(alignment: .leading, spacing: OxSpace.md) {
                        hero
                        caption
                        stichosRail
                        noteLine
                        verbs
                        scopeControls
                        stat
                        facedRail
                        OxDossierCard(store: store)
                    }
                    .padding(.horizontal, OxSpace.lg)
                    .padding(.bottom, OxSpace.xl)
                }
            }
        }
        .scrollDismissesKeyboard(.interactively)
    }

    private var settled: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: OxSpace.md) {
                chrome
                Image("bph_EmptyHome")
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: OxSpace.lg * 7, maxHeight: OxSpace.lg * 7)
                    .accessibilityHidden(true)
                Text("Every saved painting is faced.")
                    .font(OxType.display(typeSize))
                    .foregroundStyle(OxPalette.ink)
                    .lineLimit(2)
                Text("Open Saved to practice one again, or Explore for another.")
                    .font(OxType.body)
                    .foregroundStyle(OxPalette.muted)
                    .lineLimit(3)
                Button("Practice again") { practiceAgain() }
                    .buttonStyle(FaceButtonStyle())
                    .disabled(store.facedWorks.isEmpty && store.works.isEmpty)
                Button("Explore") { store.present(.explore) }
                    .buttonStyle(FaceButtonStyle(prominent: false))
            }
            .padding(.horizontal, OxSpace.lg)
            .padding(.bottom, OxSpace.xl)
            .frame(maxWidth: wide ? OxSpace.band * 1.4 : .infinity, alignment: .leading)
            .frame(maxWidth: .infinity)
        }
    }

    private var paintingColumn: some View {
        VStack(alignment: .leading, spacing: OxSpace.md) {
            hero
            caption
            facedRail
            OxDossierCard(store: store)
        }
        .padding(.bottom, OxSpace.xl)
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var playColumn: some View {
        VStack(alignment: .leading, spacing: OxSpace.md) {
            stichosRail
            noteLine
            verbs
            scopeControls
            stat
        }
        .padding(.bottom, OxSpace.xl)
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    @ViewBuilder
    private var noteLine: some View {
        if visibleNote.isEmpty == false {
            Text(visibleNote)
                .font(OxType.caption)
                .foregroundStyle(OxPalette.ink)
                .lineLimit(3)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private var visibleNote: String {
        if scopeNote.isEmpty == false { return scopeNote }
        return note
    }

    private var chrome: some View {
        HStack(alignment: .center, spacing: OxSpace.sm) {
            Text("Face the words")
                .font(OxType.display(typeSize))
                .foregroundStyle(OxPalette.ink)
                .lineLimit(1)
                .minimumScaleFactor(0.75)
                .frame(maxWidth: .infinity, alignment: .leading)
            iconButton("tray.full", label: "Saved") { store.present(.saved) }
            iconButton("gearshape", label: "Settings") { store.present(.settings) }
        }
    }

    private var scopeControls: some View {
        VStack(alignment: .leading, spacing: OxSpace.sm) {
            VStack(alignment: .leading, spacing: OxSpace.xs) {
                Text("Line")
                    .font(OxType.caption)
                    .foregroundStyle(OxPalette.muted)
                    .lineLimit(1)
                HStack(spacing: OxSpace.xs) {
                    choice("Maker", selected: scopeBinding.wrappedValue == .artist) {
                        scopeBinding.wrappedValue = .artist
                    }
                    choice("Title", selected: scopeBinding.wrappedValue == .title) {
                        scopeBinding.wrappedValue = .title
                    }
                    choice("Inscription", selected: scopeBinding.wrappedValue == .curatorial) {
                        scopeBinding.wrappedValue = .curatorial
                    }
                }
                .accessibilityElement(children: .contain)
                .accessibilityLabel("Line")
            }
            VStack(alignment: .leading, spacing: OxSpace.xs) {
                Text("Help")
                    .font(OxType.caption)
                    .foregroundStyle(OxPalette.muted)
                    .lineLimit(1)
                HStack(spacing: OxSpace.xs) {
                    choice("Guided", selected: store.document.drillBlind == false) {
                        blindBinding.wrappedValue = false
                    }
                    choice("Blind spot", selected: store.document.drillBlind) {
                        blindBinding.wrappedValue = true
                    }
                }
                .accessibilityElement(children: .contain)
                .accessibilityLabel("Help")
            }
        }
    }

    private func choice(_ title: String, selected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(OxType.caption)
                .foregroundStyle(selected ? OxPalette.surface : OxPalette.ink)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
                .frame(maxWidth: .infinity, minHeight: OxSpace.hit)
                .padding(.horizontal, OxSpace.xs)
                .background(
                    RoundedRectangle(cornerRadius: OxRadius.chip, style: .continuous)
                        .fill(selected ? OxPalette.accent : OxPalette.surface)
                )
                .contentShape(RoundedRectangle(cornerRadius: OxRadius.chip, style: .continuous))
        }
        .buttonStyle(OxTapStyle())
        .accessibilityAddTraits(selected ? .isSelected : AccessibilityTraits())
    }

    private var scopeBinding: Binding<FurrowField> {
        Binding(
            get: { store.liveFurrow?.field ?? store.document.lineScope ?? .artist },
            set: { field in
                if store.setLineScope(field) {
                    scopeNote = ""
                    note = ""
                } else {
                    scopeNote = "That line is too short."
                }
            }
        )
    }

    private var blindBinding: Binding<Bool> {
        Binding(
            get: { store.document.drillBlind },
            set: { store.setDrillBlind($0) }
        )
    }

    private var hero: some View {
        GeometryReader { proxy in
            let tall = wide ? proxy.size.height : proxy.size.width * 1.35
            workImage
                .frame(width: proxy.size.width, height: tall, alignment: .top)
                .frame(width: proxy.size.width, height: proxy.size.height, alignment: .top)
                .clipped()
        }
        .background(OxPalette.surface)
        .frame(maxWidth: .infinity)
        .frame(height: wide ? OxSpace.band * 2 : OxSpace.lg * 7)
        .clipShape(RoundedRectangle(cornerRadius: OxRadius.card, style: .continuous))
        .shadow(color: OxLift.color, radius: OxLift.radius, x: 0, y: OxLift.y)
        .overlay(alignment: .topTrailing) {
            if praise {
                Image("bph_SuccessMark")
                    .resizable()
                    .scaledToFit()
                    .frame(width: OxSpace.hit, height: OxSpace.hit)
                    .padding(OxSpace.sm)
                    .accessibilityHidden(true)
                    .transition(.opacity)
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(heroLabel)
        .animation(reduceMotion ? .easeOut(duration: OxMotion.press) : .easeOut(duration: OxMotion.sheet), value: praise)
        .onChange(of: praise) { _, show in
            guard show else { return }
            Task {
                try? await Task.sleep(for: .milliseconds(900))
                praise = false
            }
        }
    }

    @ViewBuilder
    private var workImage: some View {
        if let work = store.liveWork, let url = CatalogClient.thumbURL(filename: work.imageFile) {
            AsyncImage(url: url) { phase in
                switch phase {
                case .success(let image):
                    image.resizable().scaledToFill()
                default:
                    Image("bph_CardBackdrop").resizable().scaledToFill()
                }
            }
        } else {
            Image("bph_CardBackdrop")
                .resizable()
                .scaledToFill()
        }
    }

    private var caption: some View {
        VStack(alignment: .leading, spacing: OxSpace.xs) {
            Text(store.liveWork?.title ?? "Lay a caption")
                .font(OxType.title)
                .foregroundStyle(OxPalette.ink)
                .lineLimit(2)
            Text(store.liveWork?.maker ?? " ")
                .font(OxType.body)
                .foregroundStyle(OxPalette.muted)
                .lineLimit(2)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var stichosRail: some View {
        VStack(alignment: .leading, spacing: OxSpace.sm) {
            HStack(alignment: .firstTextBaseline, spacing: OxSpace.sm) {
                Text("\(store.statusCaption), \(fieldName)")
                    .font(OxType.caption)
                    .foregroundStyle(OxPalette.muted)
                    .lineLimit(1)
                    .frame(maxWidth: .infinity, alignment: .leading)
                Text(OxFigures.count(store.liveFurrow?.remainingRetrograde ?? 0))
                    .font(OxType.headline)
                    .foregroundStyle(OxPalette.ink)
                    .monospacedDigit()
                    .lineLimit(1)
                Text("Still open")
                    .font(OxType.caption)
                    .foregroundStyle(OxPalette.muted)
                    .lineLimit(1)
            }
            .accessibilityElement(children: .combine)
            OxFlowLayout(spacing: OxSpace.xs) {
                ForEach(store.liveFurrow?.stichoi ?? []) { stichos in
                    Button {
                        commit(stichos.index)
                    } label: {
                        VStack(spacing: 0) {
                            Text(stichos.shown)
                                .font(stichos.isRetrograde ? OxType.headline : OxType.body)
                                .foregroundStyle(chipInk(stichos))
                                .lineLimit(1)
                            if store.document.drillBlind == false || stichos.isCooled {
                                Text(chipMark(stichos))
                                    .font(OxType.micro)
                                    .foregroundStyle(stichos.isRetrograde && stichos.isCooled == false ? OxPalette.accent : OxPalette.muted)
                                    .lineLimit(1)
                            }
                        }
                        .padding(.horizontal, OxSpace.sm)
                        .padding(.vertical, OxSpace.xs)
                        .frame(minWidth: OxSpace.lg * 2, minHeight: OxSpace.hit)
                        .background(
                            RoundedRectangle(cornerRadius: OxRadius.chip, style: .continuous)
                                .fill(chipFill(stichos))
                        )
                        .contentShape(RoundedRectangle(cornerRadius: OxRadius.chip, style: .continuous))
                    }
                    .buttonStyle(OxTapStyle())
                    .disabled(store.fold != .turned)
                    .accessibilityLabel(chipLabel(stichos))
                }
            }
            Text(nextTap)
                .font(OxType.body)
                .foregroundStyle(OxPalette.ink)
                .lineLimit(2)
            Text(oxHand)
                .font(OxType.caption)
                .foregroundStyle(OxPalette.muted)
                .lineLimit(2)
        }
        .padding(OxSpace.sm)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: OxRadius.card, style: .continuous)
                .fill(OxPalette.surface)
        )
    }

    private func chipInk(_ stichos: Stichos) -> Color {
        if stichos.isCooled { return OxPalette.muted }
        if stichos.isRetrograde { return OxPalette.accent }
        return OxPalette.ink
    }

    private func chipFill(_ stichos: Stichos) -> Color {
        if stichos.isRetrograde && stichos.isCooled == false {
            return OxPalette.accent.opacity(0.14)
        }
        return OxPalette.background
    }

    private var verbs: some View {
        VStack(alignment: .leading, spacing: OxSpace.xs) {
            Button("Face") { faceNext() }
                .buttonStyle(FaceButtonStyle(prominent: canFace))
                .disabled(!canFace)
            HStack(spacing: OxSpace.xs) {
                quietAction("New line", enabled: canTurn) { store.turnFurrow() }
                quietAction("Retract", enabled: store.canRetract) { store.retractNewestMark() }
                quietAction("Letters", enabled: store.liveFurrow != nil) { showLetters = true }
                quietAction("Explore", enabled: true) { store.present(.explore) }
            }
        }
        .animation(.easeOut(duration: OxMotion.press), value: store.fold)
    }

    private func quietAction(_ title: String, enabled: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(OxType.caption)
                .foregroundStyle(enabled ? OxPalette.ink : OxPalette.muted)
                .lineLimit(1)
                .minimumScaleFactor(0.75)
                .frame(maxWidth: .infinity, minHeight: OxSpace.hit)
        }
        .buttonStyle(OxTapStyle())
        .disabled(enabled == false)
    }

    @ViewBuilder
    private var facedRail: some View {
        if store.facedWorks.isEmpty == false {
            VStack(alignment: .leading, spacing: OxSpace.xs) {
                Text("Recently faced")
                    .font(OxType.caption)
                    .foregroundStyle(OxPalette.muted)
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(alignment: .top, spacing: OxSpace.sm) {
                        ForEach(store.facedWorks) { work in
                            Button {
                                store.present(.saved)
                            } label: {
                                VStack(alignment: .leading, spacing: OxSpace.xs) {
                                    ShelfPicture(work: work, art: "bph_CardBackdrop")
                                        .frame(width: OxSpace.lg * 4, height: OxSpace.lg * 3)
                                        .clipShape(RoundedRectangle(cornerRadius: OxRadius.chip, style: .continuous))
                                    Text(work.title)
                                        .font(OxType.micro)
                                        .foregroundStyle(OxPalette.ink)
                                        .lineLimit(1)
                                        .frame(width: OxSpace.lg * 4, alignment: .leading)
                                }
                                .contentShape(Rectangle())
                            }
                            .buttonStyle(OxTapStyle())
                            .accessibilityLabel("\(work.title), faced")
                        }
                    }
                }
            }
        }
    }

    private var stat: some View {
        VStack(spacing: OxSpace.sm) {
            HStack(alignment: .top, spacing: OxSpace.sm) {
                statBlock(OxFigures.count(store.faceCount), "Faces filed")
                statBlock(OxFigures.count(store.yawCount), "Yaws")
                if wide {
                    statBlock(percentLabel, "Accuracy")
                    statBlock(OxFigures.count(store.practiceStreak), "Days in a row")
                }
            }
            if wide == false {
                HStack(alignment: .top, spacing: OxSpace.sm) {
                    statBlock(percentLabel, "Accuracy")
                    statBlock(OxFigures.count(store.practiceStreak), "Days in a row")
                }
            }
        }
        .padding(OxSpace.sm)
        .background(
            RoundedRectangle(cornerRadius: OxRadius.card, style: .continuous)
                .fill(OxPalette.surface)
        )
        .accessibilityElement(children: .combine)
    }

    private func statBlock(_ value: String, _ label: String) -> some View {
        VStack(alignment: .leading, spacing: OxSpace.xs) {
            Text(value)
                .font(OxType.headline)
                .foregroundStyle(OxPalette.ink)
                .monospacedDigit()
                .lineLimit(1)
                .minimumScaleFactor(0.7)
            Text(label)
                .font(OxType.micro)
                .foregroundStyle(OxPalette.muted)
                .lineLimit(2)
                .minimumScaleFactor(0.8)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var percentLabel: String {
        OxFigures.count(store.accuracyPercent) + "%"
    }

    private var lineIsOpen: Bool {
        store.fold == .turned && (store.liveFurrow?.remainingRetrograde ?? 0) > 0
    }

    private var canFace: Bool {
        store.document.drillBlind == false && lineIsOpen
    }

    private var canTurn: Bool {
        store.fold != .turned && store.turnableWorks.isEmpty == false
    }

    private var fieldName: String {
        switch store.liveFurrow?.field {
        case .title: return "title line"
        case .curatorial: return "gallery note"
        default: return "maker line"
        }
    }

    private var nextTap: String {
        if store.document.drillBlind && lineIsOpen {
            return "Read each word. Tap the ones spelled backward."
        }
        if canFace { return "Tap a backward word." }
        if canTurn { return "Lay a new line." }
        return "Save a work, then face."
    }

    /// Odd catalog indices are the return furrow. Even indices run outward.
    private var oxHand: String {
        if store.document.drillBlind && lineIsOpen {
            return "Hints are hidden. Letters shows the spelling on the line."
        }
        guard let next = store.liveFurrow?.stichoi.first(where: \.isRetrograde) else {
            return "The line reads forward."
        }
        if next.index.isMultiple(of: 2) {
            return "Ox goes out on the next backward word."
        }
        return "Ox turns back on the next backward word."
    }

    private var heroLabel: String {
        if let work = store.liveWork {
            return "\(work.title), \(work.maker)"
        }
        return "Painting"
    }

    private func chipMark(_ stichos: Stichos) -> String {
        if stichos.isCooled { return "Miss" }
        if store.document.drillBlind { return "Word \(OxFigures.count(stichos.index + 1))" }
        if stichos.isRetrograde { return "Backward" }
        return "Forward"
    }

    private func chipLabel(_ stichos: Stichos) -> String {
        if store.document.drillBlind {
            return stichos.shown
        }
        return "\(chipMark(stichos)) \(stichos.catalog)"
    }

    private func faceNext() {
        guard let index = store.liveFurrow?.stichoi.first(where: \.isRetrograde)?.index else { return }
        commit(index)
    }

    private func commit(_ index: Int) {
        scopeNote = ""
        if store.faceStichos(index) {
            facePulse += 1
            praise = true
            note = "That word now reads forward."
        } else {
            note = "That word already reads forward."
        }
    }

    private func practiceAgain() {
        guard let work = store.facedWorks.first ?? store.works.first else { return }
        let field = work.chosenField() ?? (work.lineReady(.curatorial) ? FurrowField.curatorial : nil)
        if let field {
            store.reopenForPractice(id: work.id, field: field)
        }
    }

    private func iconButton(_ symbol: String, label: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: symbol)
                .font(OxType.headline)
                .foregroundStyle(OxPalette.ink)
                .frame(width: OxSpace.hit, height: OxSpace.hit)
                .background(
                    Circle()
                        .fill(OxPalette.surface)
                )
                .contentShape(Circle())
        }
        .buttonStyle(OxTapStyle())
        .accessibilityLabel(label)
    }
}

/// Role: Furrow. Year, room, era, inventory, gallery note, and a private note.
struct OxDossierCard: View {
    @Bindable var store: FurrowStore
    @State private var draft = ""
    @State private var seenId = ""

    var body: some View {
        VStack(alignment: .leading, spacing: OxSpace.sm) {
            Text("About this painting")
                .font(OxType.headline)
                .foregroundStyle(OxPalette.ink)
                .lineLimit(1)
            if let work = store.liveWork {
                fact("Year", work.yearLabel)
                fact("Room", work.roomLabel)
                fact("Era", work.eraLabel)
                fact("Inventory", work.identity)
                if work.curatorialLine.isEmpty == false {
                    Text("Gallery note")
                        .font(OxType.caption)
                        .foregroundStyle(OxPalette.muted)
                        .lineLimit(1)
                    Text(work.curatorialLine)
                        .font(OxType.body)
                        .foregroundStyle(OxPalette.ink)
                        .lineLimit(6)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            Text("Your note")
                .font(OxType.caption)
                .foregroundStyle(OxPalette.muted)
                .lineLimit(1)
            TextField("Add a private note", text: $draft, axis: .vertical)
                .lineLimit(2...5)
                .font(OxType.body)
                .foregroundStyle(OxPalette.ink)
                .frame(minHeight: OxSpace.hit, alignment: .topLeading)
        }
        .padding(OxSpace.sm)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: OxRadius.card, style: .continuous)
                .fill(OxPalette.surface)
        )
        .onAppear { pull() }
        .onChange(of: store.liveWork?.id) { _, _ in pull() }
        .onChange(of: draft) { _, value in
            guard let id = store.liveWork?.id, id == seenId else { return }
            store.updateNote(id: id, note: value)
        }
    }

    @ViewBuilder
    private func fact(_ label: String, _ value: String) -> some View {
        if value.isEmpty == false {
            HStack(alignment: .firstTextBaseline, spacing: OxSpace.sm) {
                Text(label)
                    .font(OxType.caption)
                    .foregroundStyle(OxPalette.muted)
                    .lineLimit(1)
                    .frame(width: OxSpace.lg * 3, alignment: .leading)
                Text(value)
                    .font(OxType.body)
                    .foregroundStyle(OxPalette.ink)
                    .lineLimit(2)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }

    private func pull() {
        let id = store.liveWork?.id ?? ""
        guard id != seenId else { return }
        seenId = id
        draft = store.liveWork?.userNote ?? ""
    }
}

/// Role: Furrow. Spaced letters for the line that is open.
struct OxLetterSheet: View {
    let stichoi: [Stichos]
    let blind: Bool
    var close: () -> Void

    var body: some View {
        NavigationStack {
            List {
                ForEach(stichoi) { stichos in
                    VStack(alignment: .leading, spacing: OxSpace.xs) {
                        Text(spaced(stichos.shown))
                            .font(OxType.headline)
                            .foregroundStyle(OxPalette.ink)
                            .lineLimit(2)
                        if blind == false {
                            Text(stichos.isRetrograde ? "Spelled backward" : "Spelled forward")
                                .font(OxType.caption)
                                .foregroundStyle(OxPalette.muted)
                                .lineLimit(1)
                            Text(spaced(stichos.catalog))
                                .font(OxType.caption)
                                .foregroundStyle(OxPalette.ink)
                                .lineLimit(2)
                        }
                    }
                    .frame(maxWidth: .infinity, minHeight: OxSpace.hit, alignment: .leading)
                    .listRowBackground(OxPalette.surface)
                }
            }
            .scrollContentBackground(.hidden)
            .background(OxPalette.background.ignoresSafeArea())
            .navigationTitle("Letters")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        close()
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

    private func spaced(_ word: String) -> String {
        word.map { String($0) }.joined(separator: " ")
    }
}

struct ShelfPicture: View {
    let work: Work
    let art: String

    var body: some View {
        ZStack {
            OxPalette.surface
            if let url = CatalogClient.thumbURL(filename: work.imageFile) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .success(let image):
                        image.resizable().scaledToFill()
                    default:
                        Image(art).resizable().scaledToFill()
                    }
                }
            } else {
                Image(art).resizable().scaledToFill()
            }
        }
        .clipped()
        .accessibilityHidden(true)
    }
}
