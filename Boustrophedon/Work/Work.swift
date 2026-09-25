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

    func line(for field: FurrowField) -> String {
        switch field {
        case .artist: maker
        case .title: title
        }
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
}
