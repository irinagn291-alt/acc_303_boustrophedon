import SwiftUI

struct ContentView: View {
    @Environment(FurrowStore.self) private var store
    @Environment(\.scenePhase) private var scenePhase
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var didReadReview = false

    var body: some View {
        QuizView(store: store)
            .sheet(item: sheetItem) { item in
                sheetBody(item)
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
                OxChrome.apply()
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

    private var sheetItem: Binding<FurrowSheet?> {
        Binding(
            get: { store.sheet == .none ? nil : store.sheet },
            set: { store.present($0 ?? .none) }
        )
    }

    @ViewBuilder
    private func sheetBody(_ item: FurrowSheet) -> some View {
        switch item {
        case .none:
            EmptyView()
        case .explore:
            ExploreView(store: store)
        case .saved:
            SavedView(store: store)
        case .settings:
            SettingsView(store: store)
        case .lexicon:
            LexiconView(store: store)
        case .hangs:
            HangsView(store: store)
        case .ledger:
            LedgerView(store: store)
        case .rooms:
            RoomsView(store: store)
        case .pairs:
            PairsView(store: store)
        case .notices:
            NoticesView(store: store)
        case .checkers:
            CheckersView(store: store)
        case .library:
            LibraryView(store: store)
        }
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
