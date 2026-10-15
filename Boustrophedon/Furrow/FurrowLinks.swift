import Foundation

/// Role: Furrow. Custom scheme and site paths land on the same four jobs.
enum FurrowLinks {
    static let contact = URL(string: "https://boustrophedon-furrow.pro/contact-us")!
    static let gallery = URL(string: "https://www.nationalgallery.org.uk")!
    static let paintings = URL(string: "https://www.nationalgallery.org.uk/paintings")!

    static func destination(from url: URL) -> FurrowSheet? {
        let host = url.host?.lowercased() ?? ""
        let path = url.path.lowercased()
        let scheme = url.scheme?.lowercased() ?? ""
        let slug: String
        if scheme == "boustrophedon" {
            slug = host.isEmpty ? path.trimmingCharacters(in: CharacterSet(charactersIn: "/")) : host
        } else if host.contains("boustrophedon-furrow.pro") {
            slug = path.trimmingCharacters(in: CharacterSet(charactersIn: "/"))
        } else {
            return nil
        }
        switch slug {
        case "quiz", "": return FurrowSheet.none
        case "explore": return .explore
        case "saved": return .saved
        case "settings": return .settings
        case "lexicon", "book": return .lexicon
        case "hangs", "hang": return .hangs
        case "ledger", "route": return .ledger
        case "rooms", "room": return .rooms
        case "pairs", "pair": return .pairs
        case "notices", "notice": return .notices
        case "checkers": return .checkers
        case "library": return .library
        default: return nil
        }
    }
}
