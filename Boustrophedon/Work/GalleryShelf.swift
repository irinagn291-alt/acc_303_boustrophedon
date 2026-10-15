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
            row("NG6421", "NG6421", "Henri Rousseau", "Surprised!", "Henri_Rousseau_-_Surprised.jpg", daykey, "1891", "Room 45", "Post-Impressionism", "A tiger crouches in tall wet grass while lightning breaks the leaves."),
            row("NG508", "NG508", "Joseph Mallord William Turner", "Ulysses deriding Polyphemus", "Turner_Ulysses.jpg", daykey, "1829", "Romantic rooms", "Romanticism", "The hero's ship leaves the blinded giant as the sun lifts off the water."),
            row("NG498", "NG498", "Joseph Mallord William Turner", "Dido building Carthage", "Turner_Dido.jpg", daykey, "1815", "Romantic rooms", "Romanticism", "The queen watches a city rise beside a harbour of classical stone."),
            row("NG130", "NG130", "John Constable", "The Cornfield", "Constable_Cornfield.jpg", daykey, "1826", "Romantic rooms", "Romanticism", "A boy drinks at a stream while the lane runs on toward a field of corn."),
            row("NG725", "NG725", "Joseph Wright of Derby", "An Experiment on a Bird in the Air Pump", "Wright_Air_Pump.jpg", daykey, "1768", "British rooms", "Georgian", "A lecturer holds the life of a bird in a glass while a family watches."),
            row("NG6569", "NG6569", "George Stubbs", "Whistlejacket", "Stubbs_Whistlejacket.jpg", daykey, "about 1762", "British rooms", "Georgian", "A chestnut horse rears on an empty ground with no rider and no landscape."),
            row("NG113", "NG113", "William Hogarth", "Marriage A-la-Mode The Marriage Settlement", "Hogarth_Settlement.jpg", daykey, "about 1743", "British rooms", "Georgian", "Two fathers bargain a marriage while the young couple sit apart."),
            row("NG114", "NG114", "William Hogarth", "Marriage A-la-Mode The Tete a Tete", "Hogarth_Tete.jpg", daykey, "about 1743", "British rooms", "Georgian", "The couple breakfast in a disordered room after a night apart."),
            row("NG115", "NG115", "William Hogarth", "Marriage A-la-Mode The Inspection", "Hogarth_Inspection.jpg", daykey, "about 1743", "British rooms", "Georgian", "The young lord visits a doctor with a complaining child in tow."),
            row("NG116", "NG116", "William Hogarth", "Marriage A-la-Mode The Toilette", "Hogarth_Toilette.jpg", daykey, "about 1743", "British rooms", "Georgian", "The countess receives visitors while a singer performs in the next room."),
            row("NG117", "NG117", "William Hogarth", "Marriage A-la-Mode The Bagnio", "Hogarth_Bagnio.jpg", daykey, "about 1743", "British rooms", "Georgian", "The earl bursts in on his wife and her lover and is wounded."),
            row("NG118", "NG118", "William Hogarth", "Marriage A-la-Mode The Lady's Death", "Hogarth_Death.jpg", daykey, "about 1743", "British rooms", "Georgian", "The countess dies after poison while her child is held up to kiss her."),
            row("NG651", "NG651", "Agnolo Bronzino", "An Allegory with Venus and Cupid", "Bronzino_Allegory.jpg", daykey, "about 1545", "Italian rooms", "Mannerism", "Venus and her son are crowded by figures of pleasure, fraud, and time."),
            row("NG6337", "NG6337", "Leonardo da Vinci", "The Burlington House Cartoon", "Leonardo_Cartoon.jpg", daykey, "about 1500", "Italian rooms", "High Renaissance", "Mary and her mother sit with the two infants in a large chalk drawing."),
            row("NG168", "NG168", "Raphael", "Saint Catherine of Alexandria", "Raphael_Saint_Catherine.jpg", daykey, "about 1507", "Italian rooms", "High Renaissance", "The saint leans on her wheel and looks upward into a clear sky."),
            row("NG6596", "NG6596", "Raphael", "The Madonna of the Pinks", "Raphael_Pinks.jpg", daykey, "about 1506", "Italian rooms", "High Renaissance", "Mary and the child share a carnation in a quiet interior."),
            row("NG908", "NG908", "Piero della Francesca", "The Nativity", "Piero_Nativity.jpg", daykey, "about 1470", "Italian rooms", "Early Renaissance", "Mary kneels before the child while angels sing in a ruined shed."),
            row("NG1313", "NG1313", "Jacopo Tintoretto", "The Origin of the Milky Way", "Tintoretto_Milky_Way.jpg", daykey, "about 1575", "Italian rooms", "Venetian Renaissance", "Milk sprays from the goddess and becomes a band of stars."),
            row("NG2475", "NG2475", "Hans Holbein the Younger", "A Lady with a Squirrel and a Starling", "Holbein_Squirrel.jpg", daykey, "about 1526", "Northern rooms", "Northern Renaissance", "A woman in a fur cap holds a squirrel while a starling waits behind her."),
            row("NG3862", "NG3862", "Vincent van Gogh", "Van Gogh's Chair", "Van_Gogh_Chair.jpg", daykey, "1888", "Modern rooms", "Post-Impressionism", "A yellow chair holds a pipe and tobacco on a tiled floor."),
            row("NG3861", "NG3861", "Vincent van Gogh", "A Wheatfield with Cypresses", "Van_Gogh_Cypresses.jpg", daykey, "1889", "Modern rooms", "Post-Impressionism", "Cypresses twist above a wheat field under a rolling cloud."),
            row("NG4240", "NG4240", "Claude Monet", "The Water-Lily Pond", "Monet_Water_Lily_Pond.jpg", daykey, "1899", "Room 46", "Impressionism", "A green Japanese bridge crosses a pond of lilies."),
            row("NG6209", "NG6209", "Thomas Gainsborough", "The Morning Walk", "Gainsborough_Morning_Walk.jpg", daykey, "about 1785", "British rooms", "Georgian", "A couple stroll with a dog through pale trees in morning dress."),
            row("NG1811", "NG1811", "Thomas Gainsborough", "The Painter's Daughters chasing a Butterfly", "Gainsborough_Daughters.jpg", daykey, "about 1756", "British rooms", "Georgian", "Two girls reach after a butterfly at the edge of a wood."),
            row("NG3247", "NG3247", "Edgar Degas", "Beach Scene", "Degas_Beach_Scene.jpg", daykey, "about 1876", "Modern rooms", "Impressionism", "A woman combs a girl's hair on a wide pale beach."),
            row("NG4119", "NG4119", "Camille Pissarro", "The Boulevard Montmartre at Night", "Pissarro_Boulevard.jpg", daykey, "1897", "Modern rooms", "Impressionism", "Wet pavement takes the lights of carriages on a night boulevard."),
            row("NG6671", "NG6671", "Artemisia Gentileschi", "Self Portrait as Saint Catherine of Alexandria", "Gentileschi_Catherine.jpg", daykey, "about 1615", "Baroque rooms", "Baroque", "The painter wears a crown and rests a hand on a broken wheel.")
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
