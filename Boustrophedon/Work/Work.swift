import Foundation

/// Role: Work. One National Gallery painting on the crate. Fold lives here, not a parallel bool.
struct Work: Codable, Equatable, Identifiable, Sendable {
    var id: String
    var identity: String
    var maker: String
    var title: String
    var imageFile: String
    var daykey: Int
    var fold: Boustrophedon
    var yearLabel: String
    var roomLabel: String
    var eraLabel: String
    var curatorialLine: String
    var userNote: String

    init(
        id: String,
        identity: String,
        maker: String,
        title: String,
        imageFile: String,
        daykey: Int,
        fold: Boustrophedon,
        yearLabel: String = "",
        roomLabel: String = "",
        eraLabel: String = "",
        curatorialLine: String = "",
        userNote: String = ""
    ) {
        self.id = id
        self.identity = identity
        self.maker = maker
        self.title = title
        self.imageFile = imageFile
        self.daykey = daykey
        self.fold = fold
        self.yearLabel = yearLabel
        self.roomLabel = roomLabel
        self.eraLabel = eraLabel
        self.curatorialLine = curatorialLine
        self.userNote = userNote
    }

    func line(for field: FurrowField) -> String {
        switch field {
        case .artist: maker
        case .title: title
        case .curatorial: curatorialLine
        }
    }

    func lineReady(_ field: FurrowField) -> Bool {
        Stichos.tokens(in: line(for: field)).count >= 2
    }

    var hasPlayableLine: Bool {
        chosenField() != nil || lineReady(.curatorial)
    }

    func chosenField() -> FurrowField? {
        let artistOk = Stichos.tokens(in: maker).count >= 2
        let titleOk = Stichos.tokens(in: title).count >= 2
        switch (artistOk, titleOk) {
        case (true, false):
            return .artist
        case (false, true):
            return .title
        case (true, true):
            return identity.utf8.reduce(0) { $0 + Int($1) } & 1 == 0 ? .artist : .title
        default:
            return nil
        }
    }

    enum CodingKeys: String, CodingKey {
        case id
        case identity
        case maker
        case title
        case imageFile
        case daykey
        case fold
        case yearLabel
        case roomLabel
        case eraLabel
        case curatorialLine
        case userNote
    }

    init(from decoder: Decoder) throws {
        let box = try decoder.container(keyedBy: CodingKeys.self)
        id = try box.decode(String.self, forKey: .id)
        identity = try box.decode(String.self, forKey: .identity)
        maker = try box.decode(String.self, forKey: .maker)
        title = try box.decode(String.self, forKey: .title)
        imageFile = try box.decode(String.self, forKey: .imageFile)
        daykey = try box.decode(Int.self, forKey: .daykey)
        fold = try box.decode(Boustrophedon.self, forKey: .fold)
        yearLabel = try box.decodeIfPresent(String.self, forKey: .yearLabel) ?? ""
        roomLabel = try box.decodeIfPresent(String.self, forKey: .roomLabel) ?? ""
        eraLabel = try box.decodeIfPresent(String.self, forKey: .eraLabel) ?? ""
        curatorialLine = try box.decodeIfPresent(String.self, forKey: .curatorialLine) ?? ""
        userNote = try box.decodeIfPresent(String.self, forKey: .userNote) ?? ""
    }

    func encode(to encoder: Encoder) throws {
        var box = encoder.container(keyedBy: CodingKeys.self)
        try box.encode(id, forKey: .id)
        try box.encode(identity, forKey: .identity)
        try box.encode(maker, forKey: .maker)
        try box.encode(title, forKey: .title)
        try box.encode(imageFile, forKey: .imageFile)
        try box.encode(daykey, forKey: .daykey)
        try box.encode(fold, forKey: .fold)
        try box.encode(yearLabel, forKey: .yearLabel)
        try box.encode(roomLabel, forKey: .roomLabel)
        try box.encode(eraLabel, forKey: .eraLabel)
        try box.encode(curatorialLine, forKey: .curatorialLine)
        try box.encode(userNote, forKey: .userNote)
    }
}
