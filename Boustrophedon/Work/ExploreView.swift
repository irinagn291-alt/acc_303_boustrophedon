import SwiftUI

/// Role: Work. Search the National Gallery. Local shelf when search is empty or fails.
struct ExploreView: View {
    @Bindable var store: FurrowStore
    @State private var search = CatalogSearch()
    @State private var era = OxEraFilter.all
    @State private var writing = false

    var body: some View {
        NavigationStack {
            Group {
                if search.rows.isEmpty && search.query.isEmpty == false && search.fault != nil && displayed.isEmpty {
                    QuietPage(
                        art: "bph_EmptyList",
                        headline: "Search stayed quiet.",
                        line: "Try another word, or save from the shelf.",
                        actionTitle: "Show shelf"
                    ) {
                        search.type("", cache: store.document.cachedWorks)
                        era = .all
                    }
                } else if search.rows.isEmpty && store.document.cachedWorks.isEmpty && GalleryShelf.works(daykey: DayKey.current()).isEmpty {
                    QuietPage(
                        art: "bph_EmptyList",
                        headline: "Crate is open.",
                        line: "Save a painting so a line can start.",
                        actionTitle: "Close"
                    ) {
                        store.present(.none)
                    }
                } else {
                    list
                }
            }
            .background(OxPalette.background.ignoresSafeArea())
            .navigationTitle("Explore")
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
                ToolbarItem(placement: .primaryAction) {
                    Button("New study line") { writing = true }
                }
                ToolbarItem(placement: .secondaryAction) {
                    Button("Save all") { store.saveWorks(displayed) }
                        .disabled(displayed.isEmpty)
                }
            }
            .searchable(text: $search.query, prompt: "Maker or title")
            .onChange(of: search.query) { _, value in
                search.type(value, cache: store.document.cachedWorks)
            }
            .onAppear {
                if search.rows.isEmpty {
                    search.type("", cache: store.document.cachedWorks)
                }
            }
            .sheet(isPresented: $writing) {
                OxStudyForm(store: store) { writing = false }
                    .presentationBackground(OxPalette.surface)
                    .presentationCornerRadius(OxRadius.card)
            }
        }
    }

    private var displayed: [Work] {
        var rows = search.rows.filter { era.matches($0.eraLabel) }
        let needle = search.query.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        for work in store.works where work.id.hasPrefix("local.") {
            guard era.matches(work.eraLabel) else { continue }
            if needle.isEmpty == false {
                let blob = "\(work.maker) \(work.title) \(work.curatorialLine) \(work.eraLabel)".lowercased()
                if blob.contains(needle) == false { continue }
            }
            if rows.contains(where: { $0.id == work.id }) { continue }
            rows.append(work)
        }
        return rows
    }

    private var list: some View {
        VStack(alignment: .leading, spacing: 0) {
            eraBar
            ScrollViewReader { proxy in
                List {
                    if search.isSearching {
                        HStack(spacing: OxSpace.sm) {
                            ProgressView()
                            Text("Looking")
                                .font(OxType.body)
                                .foregroundStyle(OxPalette.muted)
                        }
                        .frame(minHeight: OxSpace.hit)
                        .listRowBackground(OxPalette.surface)
                    }
                    if let fault = search.fault {
                        VStack(alignment: .leading, spacing: OxSpace.xs) {
                            Text("Search did not finish.")
                                .font(OxType.headline)
                                .foregroundStyle(OxPalette.ink)
                            Text(fault == .transport ? "The gallery link paused." : "The reply could not be read.")
                                .font(OxType.caption)
                                .foregroundStyle(OxPalette.muted)
                            Button("Try again") { search.type(search.query, cache: store.document.cachedWorks) }
                                .buttonStyle(FaceButtonStyle())
                        }
                        .listRowBackground(OxPalette.surface)
                    }
                    if displayed.isEmpty {
                        VStack(alignment: .leading, spacing: OxSpace.sm) {
                            Text("Nothing in this group.")
                                .font(OxType.headline)
                                .foregroundStyle(OxPalette.ink)
                            Button("Show all") {
                                era = .all
                                search.type("", cache: store.document.cachedWorks)
                            }
                            .buttonStyle(FaceButtonStyle(prominent: false))
                        }
                        .listRowBackground(OxPalette.surface)
                    }
                    ForEach(displayed) { work in
                        row(work)
                    }
                }
                .scrollContentBackground(.hidden)
                .scrollDismissesKeyboard(.interactively)
                .onAppear {
                    if let id = store.document.focusedWorkId {
                        proxy.scrollTo(id, anchor: .center)
                    }
                }
                .onChange(of: store.document.focusedWorkId) { _, id in
                    guard let id else { return }
                    proxy.scrollTo(id, anchor: .center)
                }
            }
        }
    }

    private var eraBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: OxSpace.xs) {
                ForEach(OxEraFilter.allCases) { item in
                    Button(item.title) { era = item }
                        .buttonStyle(OxTapStyle())
                        .font(OxType.caption)
                        .foregroundStyle(era == item ? OxPalette.surface : OxPalette.ink)
                        .padding(.horizontal, OxSpace.sm)
                        .frame(minHeight: OxSpace.hit)
                        .background(
                            RoundedRectangle(cornerRadius: OxRadius.chip, style: .continuous)
                                .fill(era == item ? OxPalette.accent : OxPalette.surface)
                        )
                        .accessibilityAddTraits(era == item ? .isSelected : AccessibilityTraits())
                }
            }
            .padding(.horizontal, OxSpace.lg)
            .padding(.vertical, OxSpace.xs)
        }
        .accessibilityLabel("Era")
    }

    private func row(_ work: Work) -> some View {
        let known = store.works.contains { $0.id == work.id }
        return VStack(alignment: .leading, spacing: OxSpace.xs) {
            HStack(alignment: .center, spacing: OxSpace.sm) {
                ShelfPicture(work: work, art: "bph_OxFurrow")
                    .frame(width: OxSpace.sm * 5, height: OxSpace.lg * 2)
                    .clipShape(RoundedRectangle(cornerRadius: OxRadius.chip, style: .continuous))
                VStack(alignment: .leading, spacing: OxSpace.xs) {
                    Text(work.title)
                        .font(OxType.headline)
                        .foregroundStyle(OxPalette.ink)
                        .lineLimit(2)
                    Text(work.maker)
                        .font(OxType.caption)
                        .foregroundStyle(OxPalette.muted)
                        .lineLimit(1)
                    if work.eraLabel.isEmpty == false {
                        Text(work.eraLabel)
                            .font(OxType.micro)
                            .foregroundStyle(OxPalette.muted)
                            .lineLimit(1)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            HStack(spacing: OxSpace.sm) {
                if known {
                    Text("In crate")
                        .font(OxType.caption)
                        .foregroundStyle(OxPalette.accent)
                        .frame(minHeight: OxSpace.hit)
                } else {
                    Button("Save") {
                        store.saveWork(work)
                        store.rememberCache([work])
                    }
                    .buttonStyle(OxTapStyle())
                    .font(OxType.headline)
                    .foregroundStyle(OxPalette.ink)
                    .frame(minHeight: OxSpace.hit)
                }
                Button("Practice") { practice(work) }
                    .buttonStyle(OxTapStyle())
                    .font(OxType.headline)
                    .foregroundStyle(OxPalette.accent)
                    .frame(minHeight: OxSpace.hit)
            }
        }
        .frame(maxWidth: .infinity, minHeight: OxSpace.hit, alignment: .leading)
        .contentShape(Rectangle())
        .id(work.id)
        .listRowBackground(OxPalette.surface)
    }

    private func practice(_ work: Work) {
        store.saveWork(work)
        let preferred = store.document.lineScope
        let field = preferred.flatMap { work.lineReady($0) ? $0 : nil }
            ?? work.chosenField()
            ?? (work.lineReady(.curatorial) ? FurrowField.curatorial : nil)
        if let field {
            store.reopenForPractice(id: work.id, field: field)
        }
        store.present(.none)
    }
}

enum OxEraFilter: String, CaseIterable, Identifiable {
    case all
    case renaissance
    case baroque
    case romantic
    case modern

    var id: String { rawValue }

    var title: String {
        switch self {
        case .all: return "All"
        case .renaissance: return "Renaissance"
        case .baroque: return "Baroque"
        case .romantic: return "Romantic"
        case .modern: return "Modern"
        }
    }

    func matches(_ era: String) -> Bool {
        switch self {
        case .all:
            return true
        case .renaissance:
            return era.localizedCaseInsensitiveContains("renaissance")
        case .baroque:
            return era.localizedCaseInsensitiveContains("baroque")
        case .romantic:
            return era.localizedCaseInsensitiveContains("romantic")
        case .modern:
            return era.localizedCaseInsensitiveContains("impression")
                || era.localizedCaseInsensitiveContains("modern")
        }
    }
}

/// Role: Work. A local caption the reader typed, kept on this device.
struct OxStudyForm: View {
    @Bindable var store: FurrowStore
    var close: () -> Void
    @State private var title = ""
    @State private var maker = ""
    @State private var era = "Renaissance"
    @State private var caption = ""
    @State private var fault = ""

    var body: some View {
        NavigationStack {
            Form {
                TextField("", text: $title, prompt: Text("Title").foregroundStyle(OxPalette.muted))
                    .foregroundStyle(OxPalette.ink)
                    .listRowBackground(OxPalette.surface)
                TextField("", text: $maker, prompt: Text("Maker").foregroundStyle(OxPalette.muted))
                    .foregroundStyle(OxPalette.ink)
                    .listRowBackground(OxPalette.surface)
                Picker("Era", selection: $era) {
                    Text("Renaissance").tag("Renaissance")
                    Text("Baroque").tag("Baroque")
                    Text("Romantic").tag("Romantic")
                    Text("Modern").tag("Modern")
                }
                .foregroundStyle(OxPalette.ink)
                .listRowBackground(OxPalette.surface)
                TextField("", text: $caption, prompt: Text("Gallery note").foregroundStyle(OxPalette.muted), axis: .vertical)
                    .lineLimit(3...6)
                    .foregroundStyle(OxPalette.ink)
                    .listRowBackground(OxPalette.surface)
                if fault.isEmpty == false {
                    Text(fault)
                        .font(OxType.caption)
                        .foregroundStyle(OxPalette.ink)
                }
                Button("Save line") { commit() }
                    .buttonStyle(FaceButtonStyle())
            }
            .scrollContentBackground(.hidden)
            .background(OxPalette.background.ignoresSafeArea())
            .navigationTitle("New study line")
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

    private func commit() {
        if store.addCustomEntry(title: title, maker: maker, era: era, caption: caption) {
            close()
        } else {
            fault = "Use at least two words in the maker, the title, or the gallery note."
        }
    }
}
