import Foundation

/// Role: Work. Local National Gallery shelf so empty or failed search still turns.
enum GalleryShelf {
    static func works(daykey: Int) -> [Work] {
        [
            row("Q219831", "NG186", "Jan van Eyck", "The Arnolfini Portrait", "Van_Eyck_-_Arnolfini_Portrait.jpg", daykey, "1434", "Northern rooms", "Northern Renaissance", "Oil on oak shows a couple in a quiet room with a mirror and a small dog."),
            row("Q11825", "NG524", "Joseph Mallord William Turner", "The Fighting Temeraire", "Turner_-_The_Fighting_Temeraire.jpg", daykey, "1839", "Romantic rooms", "Romanticism", "A tug draws the old warship onward to be broken up at sunset."),
            row("Q186894", "NG120", "John Constable", "The Hay Wain", "John_Constable_-_The_Hay_Wain.jpg", daykey, "1821", "Romantic rooms", "Romanticism", "A wagon crosses the river in front of a mill under a wide sky."),
            row("Q12418", "NG1314", "Hans Holbein the Younger", "The Ambassadors", "Hans_Holbein_the_Younger_-_The_Ambassadors.jpg", daykey, "1533", "Northern rooms", "Northern Renaissance", "Two envoys stand by a table of instruments with a stretched skull in front."),
            row("Q243083", "NG3863", "Vincent van Gogh", "Sunflowers", "Vincent_van_Gogh_-_Sunflowers_-_VGM.jpg", daykey, "1888", "Modern rooms", "Post-Impressionism", "Yellow blooms fill a vase against a pale ground in thick paint."),
            row("Q154470", "NG3908", "Georges Seurat", "Bathers at Asnieres", "Georges_Seurat_-_Bathers_at_Asnieres.jpg", daykey, "1884", "Modern rooms", "Post-Impressionism", "Figures rest by the river while factory smoke sits on the far bank."),
            row("Q186892", "NG538", "Joseph Mallord William Turner", "Rain Steam and Speed", "Turner-rain-steam-and-speed.jpg", daykey, "1844", "Romantic rooms", "Romanticism", "A train crosses the bridge through rain and steam beside a bright hare."),
            row("Q47597", "NG915", "Sandro Botticelli", "Venus and Mars", "Sandro_Botticelli_-_Venus_and_Mars.jpg", daykey, "about 1485", "Italian rooms", "Early Renaissance", "Venus watches Mars sleep while satyrs play with his armor."),
            row("NG1093", "NG1093", "Leonardo da Vinci", "The Virgin of the Rocks", "Leonardo_da_Vinci_-_Virgin_of_the_Rocks.jpg", daykey, "about 1491", "Italian rooms", "Early Renaissance", "Mary kneels with the infants and an angel in a dark rocky grotto."),
            row("NG583", "NG583", "Paolo Uccello", "The Battle of San Romano", "Paolo_Uccello_-_The_Battle_of_San_Romano.jpg", daykey, "about 1438", "Italian rooms", "Early Renaissance", "Niccolo da Tolentino leads the Florentine troops among broken lances."),
            row("NG665", "NG665", "Piero della Francesca", "The Baptism of Christ", "Piero_della_Francesca_-_The_Baptism_of_Christ.jpg", daykey, "about 1450", "Italian rooms", "Early Renaissance", "Christ stands in the river while the dove hovers in a pale sky."),
            row("NG1034", "NG1034", "Sandro Botticelli", "Mystic Nativity", "Sandro_Botticelli_-_Mystic_Nativity.jpg", daykey, "1500", "Italian rooms", "Early Renaissance", "Angels dance above the stable while shepherds and kings draw near."),
            row("NG1171", "NG1171", "Raphael", "The Ansidei Madonna", "Raphael_-_The_Ansidei_Madonna.jpg", daykey, "1505", "Italian rooms", "Early Renaissance", "Mary sits enthroned with the child between two standing saints."),
            row("NG35", "NG35", "Titian", "Bacchus and Ariadne", "Titian_-_Bacchus_and_Ariadne.jpg", daykey, "1520 to 1523", "Italian rooms", "Venetian Renaissance", "Bacchus leaps from the chariot as Ariadne turns on the shore."),
            row("NG172", "NG172", "Michelangelo Merisi da Caravaggio", "The Supper at Emmaus", "Caravaggio_-_Supper_at_Emmaus.jpg", daykey, "1601", "Baroque rooms", "Baroque", "The risen guest blesses the bread while the two companions start back."),
            row("NG2057", "NG2057", "Diego Velazquez", "The Rokeby Venus", "Diego_Velazquez_-_Rokeby_Venus.jpg", daykey, "about 1647", "Baroque rooms", "Baroque", "Venus reclines with her back to us and meets our gaze in a mirror."),
            row("NG6350", "NG6350", "Rembrandt van Rijn", "Belshazzar's Feast", "Rembrandt_-_Belshazzar_Feast.jpg", daykey, "about 1636", "Baroque rooms", "Baroque", "The king turns in alarm as the writing appears on the wall."),
            row("NG1383", "NG1383", "Johannes Vermeer", "A Young Woman standing at a Virginal", "Johannes_Vermeer_-_Young_Woman_at_a_Virginal.jpg", daykey, "about 1670", "Baroque rooms", "Baroque", "A woman stands at the keyboard in a quiet room of cool light."),
            row("NG127", "NG127", "Canaletto", "The Stonemason's Yard", "Canaletto_-_The_Stonemason_Yard.jpg", daykey, "about 1725", "Baroque rooms", "Baroque", "Masons work in a Venetian campo while laundry hangs in the sun."),
            row("NG6301", "NG6301", "Thomas Gainsborough", "Mr and Mrs Andrews", "Thomas_Gainsborough_-_Mr_and_Mrs_Andrews.jpg", daykey, "about 1750", "British rooms", "Georgian", "The couple sit under an oak with their estate rolling out behind them."),
            row("NG6343", "NG6343", "Claude Monet", "Water-Lilies", "Claude_Monet_-_Water-Lilies.jpg", daykey, "after 1916", "Room 46", "Impressionism", "Lily pads float on a pond with no horizon and no near bank."),
            row("NG3268", "NG3268", "Pierre Auguste Renoir", "The Umbrellas", "Pierre-Auguste_Renoir_-_The_Umbrellas.jpg", daykey, "about 1881", "Modern rooms", "Impressionism", "A crowd passes in the rain under a blue and grey canopy of umbrellas."),
            row("NG6359", "NG6359", "Paul Cezanne", "Bathers", "Paul_Cezanne_-_Bathers.jpg", daykey, "about 1894", "Modern rooms", "Post-Impressionism", "Figures stand among trees in a blue landscape built from flat patches."),
            row("NG6421", "NG6421", "Henri Rousseau", "Surprised!", "Henri_Rousseau_-_Surprised.jpg", daykey, "1891", "Room 45", "Post-Impressionism", "A tiger crouches in tall wet grass while lightning breaks the leaves.")
        ]
    }

    static func matching(query: String, daykey: Int) -> [Work] {
        let needle = query.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        let all = works(daykey: daykey)
        guard !needle.isEmpty else { return all }
        return all.filter {
            $0.maker.lowercased().contains(needle)
                || $0.title.lowercased().contains(needle)
                || $0.curatorialLine.lowercased().contains(needle)
                || $0.eraLabel.lowercased().contains(needle)
        }
    }

    private static func row(
        _ id: String,
        _ identity: String,
        _ maker: String,
        _ title: String,
        _ imageFile: String,
        _ daykey: Int,
        _ year: String,
        _ room: String,
        _ era: String,
        _ line: String
    ) -> Work {
        Work(
            id: id,
            identity: identity,
            maker: maker,
            title: title,
            imageFile: imageFile,
            daykey: daykey,
            fold: .idle,
            yearLabel: year,
            roomLabel: room,
            eraLabel: era,
            curatorialLine: line
        )
    }
}
