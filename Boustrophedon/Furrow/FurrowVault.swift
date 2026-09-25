import Foundation

/// Role: Furrow. Atomic file projection off the main thread. UserDefaults stays the named store.
actor FurrowVault {
    static let defaultsKey = "bph.furrow.v1"
    static let backupKey = "bph.furrow.v1.backup"

    let suiteName: String?
    let folder: URL

    init(suiteName: String? = nil, folder: URL) {
        self.suiteName = suiteName
        self.folder = folder
    }

    private var defaults: UserDefaults {
        if let suiteName {
            return UserDefaults(suiteName: suiteName) ?? .standard
        }
        return .standard
    }

    func load() -> FurrowDocument {
        if let cached = defaultsDocument() { return cached }
        if let data = try? Data(contentsOf: fileURL), let doc = Self.decode(data) {
            return doc
        }
        if let data = try? Data(contentsOf: backupURL), let doc = Self.decode(data) {
            return doc
        }
        return .empty()
    }

    nonisolated func peek() -> FurrowDocument {
        defaultsDocument() ?? .empty()
    }

    nonisolated private func defaultsDocument() -> FurrowDocument? {
        let store: UserDefaults
        if let suiteName {
            store = UserDefaults(suiteName: suiteName) ?? .standard
        } else {
            store = .standard
        }
        if let data = store.data(forKey: Self.defaultsKey), let doc = Self.decode(data) {
            return doc
        }
        if let data = store.data(forKey: Self.backupKey), let doc = Self.decode(data) {
            return doc
        }
        return nil
    }

    func save(_ document: FurrowDocument) {
        let encoder = JSONEncoder()
        guard let data = try? encoder.encode(document) else { return }
        if let previous = defaults.data(forKey: Self.defaultsKey) {
            defaults.set(previous, forKey: Self.backupKey)
        }
        defaults.set(data, forKey: Self.defaultsKey)
        try? FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
        if FileManager.default.fileExists(atPath: fileURL.path),
           let previous = try? Data(contentsOf: fileURL) {
            try? previous.write(to: backupURL, options: .atomic)
        }
        try? data.write(to: fileURL, options: .atomic)
    }

    func wipe() {
        defaults.removeObject(forKey: Self.defaultsKey)
        defaults.removeObject(forKey: Self.backupKey)
        try? FileManager.default.removeItem(at: fileURL)
        try? FileManager.default.removeItem(at: backupURL)
    }

    private var fileURL: URL { folder.appendingPathComponent("furrow.json") }
    private var backupURL: URL { folder.appendingPathComponent("furrow.json.backup") }

    private nonisolated static func decode(_ data: Data) -> FurrowDocument? {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .useDefaultKeys
        guard let doc = try? decoder.decode(FurrowDocument.self, from: data) else { return nil }
        guard doc.schemaVersion >= 1 else { return nil }
        return doc
    }
}
