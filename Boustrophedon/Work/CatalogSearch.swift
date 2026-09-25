import Foundation
import Observation

/// Role: Work. Debounced SPARQL search. Empty query never hits the network.
@MainActor
@Observable
final class CatalogSearch {
    var query = ""
    var rows: [Work] = []
    var fault: CatalogFault?
    var isSearching = false
    var didWait = false

    private let client: CatalogClient
    private var task: Task<Void, Never>?
    private var spinnerTask: Task<Void, Never>?

    init(client: CatalogClient = CatalogClient()) {
        self.client = client
    }

    func type(_ text: String, cache: [Work]) {
        query = text
        task?.cancel()
        spinnerTask?.cancel()
        fault = nil
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty {
            isSearching = false
            rows = cache.isEmpty ? GalleryShelf.matching(query: "", daykey: DayKey.current()) : cache
            return
        }
        task = Task { [weak self] in
            try? await Task.sleep(for: .milliseconds(500))
            guard let self, !Task.isCancelled else { return }
            await self.run(trimmed, cache: cache)
        }
    }

    private func run(_ trimmed: String, cache: [Work]) async {
        spinnerTask = Task {
            try? await Task.sleep(for: .milliseconds(150))
            if !Task.isCancelled { isSearching = true }
        }
        do {
            let found = try await client.search(query: trimmed, page: 1, pageSize: 12)
            rows = found.isEmpty ? GalleryShelf.matching(query: trimmed, daykey: DayKey.current()) : found
            fault = found.isEmpty && cache.isEmpty ? nil : nil
            if found.isEmpty && rows.isEmpty {
                rows = cache
                if rows.isEmpty { fault = .malformed }
            }
        } catch is CancellationError {
            return
        } catch let catalog as CatalogFault {
            if catalog == .cancelled { return }
            fault = catalog
            rows = GalleryShelf.matching(query: trimmed, daykey: DayKey.current())
            if rows.isEmpty { rows = cache }
        } catch {
            fault = .transport
            rows = GalleryShelf.matching(query: trimmed, daykey: DayKey.current())
        }
        spinnerTask?.cancel()
        isSearching = false
    }
}
