import Foundation

/// Role: Work. Local National Gallery shelf so empty or failed search still turns.
enum GalleryShelf {
    static func works(daykey: Int) -> [Work] {
        [
            Work(
                id: "Q219831",
                identity: "NG186",
                maker: "Jan van Eyck",
                title: "The Arnolfini Portrait",
                imageFile: "Van_Eyck_-_Arnolfini_Portrait.jpg",
                daykey: daykey,
                fold: .idle
            ),
            Work(
                id: "Q11825",
                identity: "NG524",
                maker: "Joseph Mallord William Turner",
                title: "The Fighting Temeraire",
                imageFile: "Turner_-_The_Fighting_Temeraire.jpg",
                daykey: daykey,
                fold: .idle
            ),
            Work(
                id: "Q186894",
                identity: "NG120",
                maker: "John Constable",
                title: "The Hay Wain",
                imageFile: "John_Constable_-_The_Hay_Wain.jpg",
                daykey: daykey,
                fold: .idle
            ),
            Work(
                id: "Q12418",
                identity: "NG1314",
                maker: "Hans Holbein the Younger",
                title: "The Ambassadors",
                imageFile: "Hans_Holbein_the_Younger_-_The_Ambassadors.jpg",
                daykey: daykey,
                fold: .idle
            ),
            Work(
                id: "Q243083",
                identity: "NG3863",
                maker: "Vincent van Gogh",
                title: "Sunflowers",
                imageFile: "Vincent_van_Gogh_-_Sunflowers_-_VGM.jpg",
                daykey: daykey,
                fold: .idle
            ),
            Work(
                id: "Q154470",
                identity: "NG3908",
                maker: "Georges Seurat",
                title: "Bathers at Asnieres",
                imageFile: "Georges_Seurat_-_Bathers_at_Asnieres.jpg",
                daykey: daykey,
                fold: .idle
            ),
            Work(
                id: "Q186892",
                identity: "NG538",
                maker: "Joseph Mallord William Turner",
                title: "Rain Steam and Speed",
                imageFile: "Turner-rain-steam-and-speed.jpg",
                daykey: daykey,
                fold: .idle
            ),
            Work(
                id: "Q47597",
                identity: "NG915",
                maker: "Sandro Botticelli",
                title: "Venus and Mars",
                imageFile: "Sandro_Botticelli_-_Venus_and_Mars.jpg",
                daykey: daykey,
                fold: .idle
            )
        ]
    }

    static func matching(query: String, daykey: Int) -> [Work] {
        let needle = query.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        let all = works(daykey: daykey)
        guard !needle.isEmpty else { return all }
        return all.filter {
            $0.maker.lowercased().contains(needle) || $0.title.lowercased().contains(needle)
        }
    }
}
