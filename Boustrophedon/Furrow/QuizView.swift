import SwiftUI

/// Role: Furrow. Locked ox-plough line. Turn and Face fuse here. Sheets leave the furrow in place.
struct QuizView: View {
    @Bindable var store: FurrowStore
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.dynamicTypeSize) private var typeSize
    @State private var facePulse = 0
    @State private var praise = false
    @State private var note = ""

    var body: some View {
        Group {
            if store.turnableWorks.isEmpty {
                QuietPage(
                    art: "bph_EmptyHome",
                    headline: "Crate level.",
                    line: "Save a work, then face.",
                    actionTitle: "Explore"
                ) {
                    store.present(.explore)
                }
            } else {
                furrow
            }
        }
        .background(OxPalette.background.ignoresSafeArea())
        .sensoryFeedback(.success, trigger: facePulse)
    }

    private var furrow: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: OxSpace.md) {
                chrome
                hero
                caption
                stichosRail
                Text(note.isEmpty ? " " : note)
                    .font(OxType.caption)
                    .foregroundStyle(note.isEmpty ? OxPalette.background : OxPalette.ink)
                    .lineLimit(2)
                    .frame(maxWidth: .infinity, minHeight: OxSpace.md, alignment: .leading)
                    .accessibilityHidden(note.isEmpty)
                verbs
                facedRail
                stat
            }
            .padding(.horizontal, OxSpace.lg)
            .padding(.top, OxSpace.sm)
            .padding(.bottom, OxSpace.xl)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .scrollDismissesKeyboard(.interactively)
    }

    private var chrome: some View {
        VStack(alignment: .leading, spacing: OxSpace.sm) {
            HStack(alignment: .center, spacing: OxSpace.sm) {
                Image("bph_HeaderDecor")
                    .resizable()
                    .scaledToFit()
                    .frame(height: OxSpace.hit)
                    .frame(maxWidth: OxSpace.band / 2, alignment: .leading)
                    .clipped()
                    .accessibilityHidden(true)
                Spacer(minLength: OxSpace.xs)
                iconButton("tray.full", label: "Saved") { store.present(.saved) }
                iconButton("gearshape", label: "Settings") { store.present(.settings) }
            }
            Text("Face the words")
                .font(OxType.display(typeSize))
                .foregroundStyle(OxPalette.ink)
                .lineLimit(2)
                .frame(maxWidth: .infinity, alignment: .leading)
            Button("Explore") { store.present(.explore) }
                .buttonStyle(FaceButtonStyle(prominent: false))
                .frame(maxWidth: OxSpace.lg * 6)
        }
    }

    private var hero: some View {
        ZStack {
            OxPalette.surface
            Image("bph_CardBackdrop")
                .resizable()
                .scaledToFill()
            workImage
            if praise {
                Image("bph_SuccessMark")
                    .resizable()
                    .scaledToFit()
                    .frame(width: OxSpace.hit, height: OxSpace.hit)
                    .padding(OxSpace.sm)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
                    .accessibilityHidden(true)
                    .transition(.opacity)
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: OxSpace.band)
        .clipShape(RoundedRectangle(cornerRadius: OxRadius.card, style: .continuous))
        .shadow(color: OxLift.color, radius: OxLift.radius, x: 0, y: OxLift.y)
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
                    Image("bph_OxFurrow").resizable().scaledToFit().padding(OxSpace.lg)
                }
            }
        } else {
            Image("bph_OxFurrow")
                .resizable()
                .scaledToFit()
                .padding(OxSpace.lg)
        }
    }

    private var caption: some View {
        VStack(alignment: .leading, spacing: OxSpace.xs) {
            Text(store.liveWork?.title ?? "Lay a caption")
                .font(OxType.headline)
                .foregroundStyle(OxPalette.ink)
                .lineLimit(1)
            Text(store.liveWork?.maker ?? " ")
                .font(OxType.body)
                .foregroundStyle(OxPalette.ink)
                .lineLimit(1)
            Text("\(store.statusCaption), \(fieldName)")
                .font(OxType.caption)
                .foregroundStyle(OxPalette.muted)
                .lineLimit(1)
            Text(nextTap)
                .font(OxType.body)
                .foregroundStyle(OxPalette.ink)
                .lineLimit(2)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var stichosRail: some View {
        ZStack(alignment: .bottomLeading) {
            FurrowTray()
                .fill(.ultraThinMaterial)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: OxSpace.sm) {
                    ForEach(store.liveFurrow?.stichoi ?? []) { stichos in
                        Button {
                            commit(stichos.index)
                        } label: {
                            VStack(alignment: .leading, spacing: OxSpace.xs) {
                                Text(stichos.shown)
                                    .font(stichos.isRetrograde ? OxType.headline : OxType.body)
                                    .foregroundStyle(stichos.isCooled ? OxPalette.muted : OxPalette.ink)
                                    .lineLimit(1)
                                Text(chipMark(stichos))
                                    .font(OxType.micro)
                                    .foregroundStyle(stichos.isCooled ? OxPalette.muted : OxPalette.ink)
                                    .lineLimit(1)
                            }
                            .padding(.horizontal, OxSpace.sm)
                            .frame(minWidth: OxSpace.lg * 4, minHeight: OxSpace.hit, alignment: .leading)
                            .background(
                                RoundedRectangle(cornerRadius: OxRadius.chip, style: .continuous)
                                    .fill(OxPalette.surface)
                            )
                            .contentShape(RoundedRectangle(cornerRadius: OxRadius.chip, style: .continuous))
                        }
                        .buttonStyle(OxTapStyle())
                        .disabled(store.fold != .turned)
                        .accessibilityLabel(chipLabel(stichos))
                    }
                }
                .padding(OxSpace.sm)
            }
        }
        .frame(minHeight: OxSpace.lg * 4)
        .clipShape(RoundedRectangle(cornerRadius: OxRadius.card, style: .continuous))
    }

    private var verbs: some View {
        VStack(alignment: .leading, spacing: OxSpace.sm) {
            HStack(alignment: .center, spacing: OxSpace.sm) {
                Button("Face") { faceNext() }
                    .buttonStyle(FaceButtonStyle(prominent: canFace))
                    .disabled(!canFace)
                    .layoutPriority(1)
                Button("New line") { store.turnFurrow() }
                    .buttonStyle(FaceButtonStyle(prominent: canTurn))
                    .disabled(!canTurn)
                    .frame(maxWidth: OxSpace.lg * 5)
            }
            Button("Retract") { store.retractNewestMark() }
                .buttonStyle(FaceButtonStyle(prominent: false))
                .disabled(store.faceCount == 0 && store.yawCount == 0)
        }
        .animation(.easeOut(duration: OxMotion.press), value: store.fold)
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
                                    ShelfPicture(work: work, art: "bph_FacedCaption")
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
        HStack(alignment: .center, spacing: OxSpace.sm) {
            VStack(alignment: .leading, spacing: OxSpace.xs) {
                Text(OxFigures.count(store.faceCount))
                    .font(OxType.display(typeSize))
                    .foregroundStyle(OxPalette.ink)
                    .monospacedDigit()
                    .lineLimit(1)
                    .layoutPriority(1)
                Text("Faces filed")
                    .font(OxType.caption)
                    .foregroundStyle(OxPalette.muted)
                    .lineLimit(1)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            VStack(alignment: .leading, spacing: OxSpace.xs) {
                Text(OxFigures.count(store.yawCount))
                    .font(OxType.title)
                    .foregroundStyle(OxPalette.ink)
                    .monospacedDigit()
                    .lineLimit(1)
                Text("Yaws")
                    .font(OxType.micro)
                    .foregroundStyle(OxPalette.muted)
                    .lineLimit(1)
            }
            Image("bph_TwistHero")
                .resizable()
                .scaledToFit()
                .frame(width: OxSpace.hit, height: OxSpace.hit)
                .accessibilityHidden(true)
        }
        .padding(OxSpace.sm)
        .background(
            RoundedRectangle(cornerRadius: OxRadius.card, style: .continuous)
                .fill(OxPalette.surface)
        )
        .accessibilityElement(children: .combine)
    }

    private var canFace: Bool {
        store.fold == .turned && (store.liveFurrow?.remainingRetrograde ?? 0) > 0
    }

    private var canTurn: Bool {
        store.fold != .turned && store.turnableWorks.isEmpty == false
    }

    private var fieldName: String {
        store.liveFurrow?.field == .title ? "title line" : "maker line"
    }

    private var nextTap: String {
        if canFace { return "Tap a backward word." }
        if canTurn { return "Lay a new line." }
        return "Save a work, then face."
    }

    private var heroLabel: String {
        if let work = store.liveWork {
            return "\(work.title), \(work.maker)"
        }
        return "Painting"
    }

    private func chipMark(_ stichos: Stichos) -> String {
        if stichos.isCooled { return "Miss" }
        if stichos.isRetrograde { return "Backward" }
        return "Forward"
    }

    private func chipLabel(_ stichos: Stichos) -> String {
        "\(chipMark(stichos)) \(stichos.catalog)"
    }

    private func faceNext() {
        guard let index = store.liveFurrow?.stichoi.first(where: \.isRetrograde)?.index else { return }
        commit(index)
    }

    private func commit(_ index: Int) {
        if store.faceStichos(index) {
            facePulse += 1
            praise = true
            note = "That word now reads forward."
        } else {
            note = "That word already reads forward."
        }
    }

    private func iconButton(_ symbol: String, label: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: symbol)
                .font(OxType.headline)
                .foregroundStyle(OxPalette.ink)
                .frame(width: OxSpace.hit, height: OxSpace.hit)
                .background(
                    RoundedRectangle(cornerRadius: OxRadius.chip, style: .continuous)
                        .fill(OxPalette.surface)
                )
                .contentShape(RoundedRectangle(cornerRadius: OxRadius.chip, style: .continuous))
        }
        .buttonStyle(OxTapStyle())
        .accessibilityLabel(label)
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
                        Image(art).resizable().scaledToFit().padding(OxSpace.xs)
                    }
                }
            } else {
                Image(art).resizable().scaledToFit().padding(OxSpace.xs)
            }
        }
        .clipped()
        .accessibilityHidden(true)
    }
}
