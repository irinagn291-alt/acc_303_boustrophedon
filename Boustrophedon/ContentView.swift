import SwiftUI

struct ContentView: View {
    @Environment(FurrowStore.self) private var store
    @Environment(\.scenePhase) private var scenePhase
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var didReadReview = false

    var body: some View {
        QuizView(store: store)
            .sheet(isPresented: exploreBind) {
                ExploreView(store: store)
                    .presentationBackground(OxPalette.surface)
                    .presentationCornerRadius(OxRadius.card)
                    .modifier(SheetRise())
            }
            .sheet(isPresented: savedBind) {
                SavedView(store: store)
                    .presentationBackground(OxPalette.surface)
                    .presentationCornerRadius(OxRadius.card)
                    .modifier(SheetRise())
            }
            .sheet(isPresented: settingsBind) {
                SettingsView(store: store)
                    .presentationBackground(OxPalette.surface)
                    .presentationCornerRadius(OxRadius.card)
                    .modifier(SheetRise())
            }
            .fullScreenCover(isPresented: onboardingBind) {
                OnboardingView {
                    store.completeOnboarding()
                }
            }
            .onChange(of: scenePhase) { _, phase in
                if phase == .inactive || phase == .background {
                    store.flush()
                }
            }
            .onChange(of: store.document.onboardingComplete) { _, done in
                if done { readReviewOnce() }
            }
            .onAppear {
                if store.document.onboardingComplete {
                    readReviewOnce()
                }
            }
            .onOpenURL { url in
                if let dest = FurrowLinks.destination(from: url) {
                    store.present(dest)
                }
            }
            .animation(
                reduceMotion ? .easeOut(duration: OxMotion.press) : .easeOut(duration: OxMotion.sheet),
                value: store.sheet
            )
    }

    private var exploreBind: Binding<Bool> {
        Binding(get: { store.sheet == .explore }, set: { if !$0 { store.present(.none) } })
    }

    private var savedBind: Binding<Bool> {
        Binding(get: { store.sheet == .saved }, set: { if !$0 { store.present(.none) } })
    }

    private var settingsBind: Binding<Bool> {
        Binding(get: { store.sheet == .settings }, set: { if !$0 { store.present(.none) } })
    }

    private var onboardingBind: Binding<Bool> {
        Binding(get: { store.document.onboardingComplete == false }, set: { _ in })
    }

    private func readReviewOnce() {
        guard didReadReview == false else { return }
        didReadReview = true
        let arguments = ProcessInfo.processInfo.arguments
        guard arguments.contains("-ReviewScreen") else { return }
        store.applyReview(ReviewScreenKey.parse(arguments))
    }
}

/// Role: Furrow. Sheet entry scales in and fades. Reduce Motion is opacity only.
private struct SheetRise: ViewModifier {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var arrived = false

    func body(content: Content) -> some View {
        content
            .scaleEffect(reduceMotion ? 1 : (arrived ? 1 : OxMotion.sheetScale))
            .opacity(arrived ? 1 : 0)
            .onAppear {
                withAnimation(.easeOut(duration: OxMotion.sheet)) {
                    arrived = true
                }
            }
    }
}
