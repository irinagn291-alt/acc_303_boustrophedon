import SwiftUI

/// Role: Furrow. National Gallery credit, Retract, contact, onboarding, reset.
struct SettingsView: View {
    @Bindable var store: FurrowStore
    @State private var confirmReset = false

    var body: some View {
        NavigationStack {
            Form {
                Section("Sources") {
                    Link(destination: FurrowLinks.gallery) {
                        Text("The National Gallery, London")
                            .frame(maxWidth: .infinity, minHeight: OxSpace.hit, alignment: .leading)
                    }
                    Link(destination: FurrowLinks.paintings) {
                        Text("Paintings")
                            .frame(maxWidth: .infinity, minHeight: OxSpace.hit, alignment: .leading)
                    }
                    Link(destination: FurrowLinks.contact) {
                        Text("Contact us")
                            .frame(maxWidth: .infinity, minHeight: OxSpace.hit, alignment: .leading)
                    }
                }
                Section("On this device") {
                    Button("Retract") { store.retractNewestMark() }
                        .frame(minHeight: OxSpace.hit)
                        .contentShape(Rectangle())
                    Button("Show the welcome again") { store.rerunOnboarding() }
                        .frame(minHeight: OxSpace.hit)
                        .contentShape(Rectangle())
                }
                Section {
                    Button("Reset all data", role: .destructive) { confirmReset = true }
                        .buttonStyle(FaceButtonStyle(isDestructive: true))
                }
            }
            .scrollContentBackground(.hidden)
            .background(OxPalette.background.ignoresSafeArea())
            .navigationTitle("Settings")
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
            .confirmationDialog("Erase every painting and mark on this device?", isPresented: $confirmReset, titleVisibility: .visible) {
                Button("Reset all data", role: .destructive) { store.resetAllData() }
                Button("Keep", role: .cancel) {}
            }
        }
    }
}
