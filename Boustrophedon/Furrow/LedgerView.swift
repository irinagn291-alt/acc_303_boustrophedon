import SwiftUI

/// Role: Furrow. Visit route, a note for today, and the days already walked.
struct LedgerView: View {
    @Bindable var store: FurrowStore
    var showsClose: Bool = true
    @State private var note = ""
    @State private var didPull = false
    @State private var fault = ""

    private var today: Int { DayKey.current() }

    var body: some View {
        NavigationStack {
            List {
                Section("This week") {
                    week
                        .listRowBackground(OxPalette.surface)
                }
                Section("Today") {
                    TextField("What you want to remember", text: $note, axis: .vertical)
                        .lineLimit(2...5)
                        .font(OxType.body)
                        .foregroundStyle(OxPalette.ink)
                        .frame(minHeight: OxSpace.hit, alignment: .topLeading)
                        .listRowBackground(OxPalette.surface)
                }
                Section("Visit route") {
                    if store.document.route.isEmpty {
                        VStack(alignment: .leading, spacing: OxSpace.sm) {
                            Text("The route is clear.")
                                .font(OxType.headline)
                                .foregroundStyle(OxPalette.ink)
                                .lineLimit(1)
                            Text("Add the painting that is open, then walk the stops in order.")
                                .font(OxType.body)
                                .foregroundStyle(OxPalette.muted)
                                .lineLimit(3)
                        }
                        .frame(maxWidth: .infinity, minHeight: OxSpace.hit, alignment: .leading)
                        .listRowBackground(OxPalette.surface)
                    } else {
                        ForEach(store.document.route) { stop in
                            stopRow(stop)
                        }
                    }
                    if fault.isEmpty == false {
                        Text(fault)
                            .font(OxType.caption)
                            .foregroundStyle(OxPalette.ink)
                            .listRowBackground(OxPalette.surface)
                    }
                    Button("Add the open painting") { addOpen() }
                        .frame(minHeight: OxSpace.hit)
                        .listRowBackground(OxPalette.surface)
                    Button("Clear finished") { store.clearFinishedStops() }
                        .frame(minHeight: OxSpace.hit)
                        .listRowBackground(OxPalette.surface)
                        .disabled(store.document.route.contains { $0.done } == false)
                }
                Section("Days") {
                    if store.dayTallies.isEmpty {
                        Text("No days filed yet.")
                            .font(OxType.body)
                            .foregroundStyle(OxPalette.muted)
                            .frame(minHeight: OxSpace.hit, alignment: .leading)
                            .listRowBackground(OxPalette.surface)
                    } else {
                        ForEach(store.dayTallies) { tally in
                            VStack(alignment: .leading, spacing: OxSpace.xs) {
                                Text(OxFigures.daykey(tally.daykey))
                                    .font(OxType.headline)
                                    .foregroundStyle(OxPalette.ink)
                                    .monospacedDigit()
                                    .lineLimit(1)
                                Text(tallyLine(tally))
                                    .font(OxType.caption)
                                    .foregroundStyle(OxPalette.muted)
                                    .lineLimit(2)
                            }
                            .frame(maxWidth: .infinity, minHeight: OxSpace.hit, alignment: .leading)
                            .listRowBackground(OxPalette.surface)
                        }
                    }
                }
            }
            .scrollContentBackground(.hidden)
            .contentMargins(.bottom, OxSpace.lg, for: .scrollContent)
            .background(OxPalette.background.ignoresSafeArea())
            .navigationTitle("Route and days")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                if showsClose {
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
            }
            .onAppear { pull() }
            .onChange(of: note) { _, value in
                guard didPull else { return }
                store.updateDayNote(daykey: today, body: value)
            }
        }
    }

    private var week: some View {
        let active = Set(store.dayTallies.map(\.daykey))
        return HStack(spacing: OxSpace.xs) {
            ForEach(store.recentDayKeys(), id: \.self) { day in
                VStack(spacing: OxSpace.xs) {
                    Text(OxFigures.count(day % 100))
                        .font(OxType.micro)
                        .foregroundStyle(OxPalette.muted)
                        .monospacedDigit()
                        .lineLimit(1)
                    RoundedRectangle(cornerRadius: OxRadius.chip, style: .continuous)
                        .fill(active.contains(day) ? OxPalette.accent : OxPalette.background)
                        .frame(height: OxSpace.sm)
                        .accessibilityHidden(true)
                }
                .frame(maxWidth: .infinity, minHeight: OxSpace.hit)
                .accessibilityElement(children: .combine)
                .accessibilityLabel(active.contains(day) ? "\(OxFigures.daykey(day)), practiced" : "\(OxFigures.daykey(day)), quiet")
            }
        }
    }

    private func stopRow(_ stop: VisitStop) -> some View {
        let work = store.works.first { $0.id == stop.workId }
        return VStack(alignment: .leading, spacing: OxSpace.xs) {
            Text(work?.title ?? "Missing painting")
                .font(OxType.headline)
                .foregroundStyle(stop.done ? OxPalette.muted : OxPalette.ink)
                .lineLimit(1)
            Text(work?.maker ?? " ")
                .font(OxType.caption)
                .foregroundStyle(OxPalette.muted)
                .lineLimit(1)
            HStack(spacing: OxSpace.sm) {
                Button(stop.done ? "Mark open" : "Mark walked") { store.toggleStop(id: stop.id) }
                Button("Open") { store.openStop(id: stop.id) }
                Button("Up") { store.moveStop(id: stop.id, direction: -1) }
                Button("Remove") { store.removeStop(id: stop.id) }
            }
            .buttonStyle(OxTapStyle())
            .font(OxType.caption)
            .foregroundStyle(OxPalette.ink)
            .frame(minHeight: OxSpace.hit)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .listRowBackground(OxPalette.surface)
    }

    private func tallyLine(_ tally: DayTally) -> String {
        let faces = OxFigures.count(tally.faces)
        let yaws = OxFigures.count(tally.yaws)
        let ploughs = OxFigures.count(tally.ploughs)
        let benches = OxFigures.count(tally.benches)
        return "\(faces) faced, \(yaws) yaws, \(ploughs) ploughs, \(benches) benches"
    }

    private func addOpen() {
        guard let id = store.liveWork?.id else {
            fault = "Lay a line first."
            return
        }
        if store.addToRoute(workId: id) {
            fault = ""
        } else {
            fault = "That painting is already on the route."
        }
    }

    private func pull() {
        guard didPull == false else { return }
        didPull = true
        note = store.document.dayNotes.first { $0.daykey == today }?.body ?? ""
    }
}
