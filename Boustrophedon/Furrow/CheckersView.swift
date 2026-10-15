import SwiftUI

/// Role: Furrow. A full checkers board. You move, then the house answers.
struct CheckersView: View {
    @Bindable var store: FurrowStore
    var showsClose: Bool = true
    @State private var selected: Int?

    private var match: CheckersMatch { store.document.checkersMatch }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: OxSpace.md) {
                    Text(status)
                        .font(OxType.headline)
                        .foregroundStyle(OxPalette.ink)
                        .lineLimit(2)
                    HStack(spacing: OxSpace.md) {
                        tally("You", store.document.checkersWins)
                        tally("House", store.document.checkersLosses)
                    }
                    board
                    if match.winner != nil {
                        Button("New game") {
                            selected = nil
                            store.newCheckersGame()
                        }
                        .buttonStyle(FaceButtonStyle())
                    }
                }
                .padding(OxSpace.lg)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .background(OxPalette.background.ignoresSafeArea())
            .navigationTitle("Checkers")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                if showsClose {
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
            }
        }
    }

    private var status: String {
        if match.winner == .player { return "You won." }
        if match.winner == .house { return "House won." }
        if match.turn == .house { return "House is thinking." }
        if match.lock != nil { return "Jump again with the same piece." }
        return "Your move. Tap a piece, then a square."
    }

    private func tally(_ title: String, _ value: Int) -> some View {
        VStack(alignment: .leading, spacing: OxSpace.xs) {
            Text(OxFigures.count(value))
                .font(OxType.headline)
                .foregroundStyle(OxPalette.ink)
                .monospacedDigit()
                .lineLimit(1)
            Text(title)
                .font(OxType.caption)
                .foregroundStyle(OxPalette.muted)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var board: some View {
        GeometryReader { geo in
            let cell = geo.size.width / 8
            VStack(spacing: 0) {
                ForEach((0..<8).reversed(), id: \.self) { rank in
                    HStack(spacing: 0) {
                        ForEach(0..<8, id: \.self) { file in
                            square(CheckersBoard.index(file, rank))
                                .frame(width: cell, height: cell)
                        }
                    }
                }
            }
        }
        .aspectRatio(1, contentMode: .fit)
        .frame(maxWidth: .infinity)
        .clipShape(RoundedRectangle(cornerRadius: OxRadius.chip, style: .continuous))
    }

    private func square(_ index: Int) -> some View {
        let man = match.men[index]
        let legal = store.checkersMoves
        let targets = legal.filter { $0.from == selected }.map(\.to)
        let dark = CheckersBoard.dark(index)
        return Button {
            tap(index)
        } label: {
            ZStack {
                Rectangle()
                    .fill(dark ? OxPalette.surface : OxPalette.background)
                if targets.contains(index) {
                    Circle()
                        .fill(OxPalette.accent.opacity(0.45))
                        .padding(OxSpace.sm)
                }
                if let man {
                    Circle()
                        .fill(man.side == .player ? OxPalette.accent : OxPalette.ink)
                        .padding(OxSpace.xs)
                    if man.king {
                        Circle()
                            .stroke(man.side == .player ? OxPalette.ink : OxPalette.accent, lineWidth: 2)
                            .padding(OxSpace.sm)
                    }
                }
            }
            .overlay {
                if selected == index {
                    Rectangle().stroke(OxPalette.ink, lineWidth: 2)
                }
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .disabled(match.winner != nil || match.turn != .player)
        .accessibilityLabel(label(index, man: man))
    }

    private func label(_ index: Int, man: CheckersMan?) -> String {
        let file = OxFigures.count(CheckersBoard.file(index) + 1)
        let rank = OxFigures.count(CheckersBoard.rank(index) + 1)
        guard let man else { return "Empty \(file) \(rank)" }
        let who = man.side == .player ? "Your" : "House"
        let rankName = man.king ? "king" : "man"
        return "\(who) \(rankName) \(file) \(rank)"
    }

    private func tap(_ index: Int) {
        guard match.turn == .player, match.winner == nil else { return }
        if let selected, store.checkersMoves.contains(where: { $0.from == selected && $0.to == index }) {
            store.playCheckers(from: selected, to: index)
            self.selected = store.document.checkersMatch.lock
            return
        }
        guard let man = match.men[index], man.side == .player else {
            selected = nil
            return
        }
        if let lock = match.lock, lock != index {
            return
        }
        selected = index
    }
}
