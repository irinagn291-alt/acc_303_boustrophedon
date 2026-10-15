import SwiftUI

/// Role: Furrow. Credits, studio doors, and reset. Cream ink on the brown ground, never a white form.
struct SettingsView: View {
    @Bindable var store: FurrowStore
    @State private var confirmReset = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: OxSpace.lg) {
                    settingsGroup("Sources") {
                        settingsLink("The National Gallery, London", url: FurrowLinks.gallery)
                        settingsLink("Paintings", url: FurrowLinks.paintings)
                        settingsLink("Contact us", url: FurrowLinks.contact)
                    }
                    settingsGroup("Studio") {
                        settingsPush("Word book") { LexiconView(store: store, showsClose: false) }
                        settingsPush("Hangs") { HangsView(store: store, showsClose: false) }
                        settingsPush("Route and days") { LedgerView(store: store, showsClose: false) }
                        settingsPush("Rooms") { RoomsView(store: store, showsClose: false) }
                        settingsPush("Pairs") { PairsView(store: store, showsClose: false) }
                        settingsPush("Notices") { NoticesView(store: store, showsClose: false) }
                        settingsPush("Checkers") { CheckersView(store: store, showsClose: false) }
                        settingsPush("Library") { LibraryView(store: store, showsClose: false) }
                    }
                    settingsGroup("On this device") {
                        settingsButton("Retract") { store.retractNewestMark() }
                        settingsButton("Show the welcome again") { store.rerunOnboarding() }
                    }
                    Button("Reset all data", role: .destructive) { confirmReset = true }
                        .buttonStyle(FaceButtonStyle(isDestructive: true))
                }
                .padding(OxSpace.lg)
            }
            .background(OxPalette.background.ignoresSafeArea())
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
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
            .confirmationDialog("Erase every painting and mark on this device?", isPresented: $confirmReset, titleVisibility: .visible) {
                Button("Reset all data", role: .destructive) { store.resetAllData() }
                Button("Keep", role: .cancel) {}
            }
        }
    }

    private func settingsGroup<Content: View>(_ title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: OxSpace.xs) {
            Text(title)
                .font(OxType.caption)
                .foregroundStyle(OxPalette.muted)
                .lineLimit(1)
            VStack(spacing: 0) {
                content()
            }
            .background(
                RoundedRectangle(cornerRadius: OxRadius.card, style: .continuous)
                    .fill(OxPalette.surface)
            )
        }
    }

    private func settingsLink(_ title: String, url: URL) -> some View {
        Link(destination: url) {
            settingsRow(title, mark: "arrow.up.right")
        }
    }

    private func settingsPush<Destination: View>(_ title: String, @ViewBuilder destination: () -> Destination) -> some View {
        NavigationLink {
            destination()
        } label: {
            settingsRow(title, mark: "chevron.right")
        }
        .buttonStyle(.plain)
    }

    private func settingsButton(_ title: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            settingsRow(title, mark: nil)
        }
        .buttonStyle(.plain)
    }

    private func settingsRow(_ title: String, mark: String?) -> some View {
        HStack(spacing: OxSpace.sm) {
            Text(title)
                .font(OxType.body)
                .foregroundStyle(OxPalette.ink)
                .lineLimit(2)
                .frame(maxWidth: .infinity, alignment: .leading)
            if let mark {
                Image(systemName: mark)
                    .font(OxType.caption)
                    .foregroundStyle(OxPalette.muted)
            }
        }
        .padding(.horizontal, OxSpace.sm)
        .frame(minHeight: OxSpace.hit)
        .contentShape(Rectangle())
    }
}
