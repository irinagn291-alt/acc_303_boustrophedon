import SwiftUI

/// Role: Work. Search the National Gallery. Local shelf when search is empty or fails.
struct ExploreView: View {
    @Bindable var store: FurrowStore
    @State private var search = CatalogSearch()

    var body: some View {
        NavigationStack {
            Group {
                if search.rows.isEmpty && search.query.isEmpty == false && search.fault != nil {
                    QuietPage(
                        art: "bph_EmptyList",
                        headline: "Search stayed quiet.",
                        line: "Try another word, or save from the shelf.",
                        actionTitle: "Show shelf"
                    ) {
                        search.type("", cache: store.document.cachedWorks)
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
        }
    }

    private var list: some View {
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
                ForEach(search.rows) { work in
                    Button {
                        let known = store.works.contains { $0.id == work.id }
                        store.saveWork(work)
                        store.rememberCache(search.rows)
                        if known {
                            proxy.scrollTo(work.id, anchor: .center)
                        } else {
                            store.present(.none)
                        }
                    } label: {
                        HStack(alignment: .center, spacing: OxSpace.sm) {
                            ShelfPicture(work: work, art: "bph_OxFurrow")
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
                                if store.document.focusedWorkId == work.id && store.works.contains(where: { $0.id == work.id }) {
                                    Text("Already here")
                                        .font(OxType.micro)
                                        .foregroundStyle(OxPalette.accent)
                                        .lineLimit(1)
                                }
                            }
                            .frame(maxWidth: .infinity, minHeight: OxSpace.hit, alignment: .leading)
                        }
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(OxTapStyle())
                    .id(work.id)
                    .listRowBackground(OxPalette.surface)
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
