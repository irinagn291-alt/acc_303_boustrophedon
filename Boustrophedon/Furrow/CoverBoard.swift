import SwiftUI

/// Role: Furrow. Write the open line from memory. The words stay hidden until Check.
struct CoverBoard: View {
    @Bindable var store: FurrowStore
    @State private var typed = ""
    @State private var report: CoverReport?
    @State private var fault = ""
    @State private var pulse = 0
    @State private var seenId = ""

    var body: some View {
        VStack(alignment: .leading, spacing: OxSpace.sm) {
            Text("Write it from memory")
                .font(OxType.headline)
                .foregroundStyle(OxPalette.ink)
                .lineLimit(1)
            Text("The line is covered. Write the maker, the title, or the note you chose.")
                .font(OxType.caption)
                .foregroundStyle(OxPalette.muted)
                .lineLimit(3)
            TextField("What you remember", text: $typed, axis: .vertical)
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
            if let report {
                Text(resultLine(report))
                    .font(OxType.body)
                    .foregroundStyle(OxPalette.ink)
                    .lineLimit(2)
                if report.missing.isEmpty == false {
                    Text("Missing \(report.missing.joined(separator: ", "))")
                        .font(OxType.caption)
                        .foregroundStyle(OxPalette.muted)
                        .lineLimit(3)
                }
                if report.extras.isEmpty == false {
                    Text("Extra \(report.extras.joined(separator: ", "))")
                        .font(OxType.caption)
                        .foregroundStyle(OxPalette.muted)
                        .lineLimit(3)
                }
            }
            Button("Check") { check() }
                .buttonStyle(FaceButtonStyle())
        }
        .padding(OxSpace.sm)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: OxRadius.card, style: .continuous)
                .fill(OxPalette.surface)
        )
        .sensoryFeedback(.success, trigger: pulse)
        .onAppear { pull() }
        .onChange(of: store.liveWork?.id) { _, _ in pull() }
        .onChange(of: store.liveFurrow?.field) { _, _ in
            report = nil
            fault = ""
        }
    }

    private func resultLine(_ report: CoverReport) -> String {
        let hits = OxFigures.count(report.hits.count)
        let total = OxFigures.count(report.hits.count + report.missing.count)
        if report.full { return "The whole line is there. \(hits) of \(total)." }
        return "\(hits) of \(total) words."
    }

    private func check() {
        if let graded = store.fileCover(typed: typed) {
            report = graded
            fault = ""
            if graded.full { pulse += 1 }
        } else {
            fault = "Use at least two words."
            report = nil
        }
    }

    private func pull() {
        let id = store.liveWork?.id ?? ""
        guard id != seenId else { return }
        seenId = id
        typed = ""
        report = nil
        fault = ""
    }
}
