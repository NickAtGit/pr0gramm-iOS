import UIKit

enum Mark: Int, Codable {
    case schwuchtel
    case neuschwuchtel
    case altschwuchtel
    case administrator
    case gebannt
    case moderator
    case fliesentisch
    case lebendeLegende
    case wichtel
    case edlerSpender
    case mittelaltschwuchtel
    case ehemaligerModerator
    case communityHelfer
    case nutzerBot
    case systemBot
    case ehemaligerHelfer
    case unbekannt
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let value = try container.decode(Int.self)
        self = Mark(rawValue: value) ?? .unbekannt
    }
    
    // Slightly different from color names
    var title: String {
        switch self {
        case .schwuchtel:          "Schwuchtel"
        case .neuschwuchtel:       "Neuschwuchtel"
        case .altschwuchtel:       "Altschwuchtel"
        case .administrator:       "Admin"
        case .gebannt:             "Gesperrt"
        case .moderator:           "Moderator"
        case .fliesentisch:        "Fliesentischbesitzer"
        case .lebendeLegende:      "Lebende Legende"
        case .wichtel:             "Wichtler"
        case .edlerSpender:        "Edler Spender"
        case .mittelaltschwuchtel: "Mittelaltschwuchtel"
        case .ehemaligerModerator: "Ehemaliger Moderator"
        case .communityHelfer:     "Community-Helfer"
        case .nutzerBot:           "Nutzer-Bot"
        case .systemBot:           "System-Bot"
        case .ehemaligerHelfer:    "Ehemaliger Helfer"
        case .unbekannt:           "Unbekannt"
        }
    }
    
    // Source: https://pr0gramm.com/upload-info
    var icon: UIImage {
        switch self {
        case .schwuchtel:          .Mark.dot.withTintColor(.Mark.schwuchtel)
        case .neuschwuchtel:       .Mark.dot.withTintColor(.Mark.neuschwuchtel)
        case .altschwuchtel:       .Mark.dot.withTintColor(.Mark.altschwuchtel)
        case .administrator:       .Mark.dot.withTintColor(.Mark.administrator)
        case .gebannt:             .Mark.dot.withTintColor(.Mark.gebannt)
        case .moderator:           .Mark.dot.withTintColor(.Mark.moderator)
        case .fliesentisch:        .Mark.dot.withTintColor(.Mark.fliesentisch)
        case .lebendeLegende:      .Mark.diamond.withTintColor(.Mark.lebendeLegende)
        case .wichtel:             .Mark.scattered.withTintColor(.Mark.wichtel)
        case .edlerSpender:        .Mark.dot.withTintColor(.Mark.edlerSpender)
        case .mittelaltschwuchtel: .Mark.dot.withTintColor(.Mark.mittelaltschwuchtel)
        case .ehemaligerModerator: .Mark.dot.withTintColor(.Mark.ehemaligerModerator)
        case .communityHelfer:     .Mark.heart.withTintColor(.Mark.communityHelfer)
        case .nutzerBot:           .Mark.dot.withTintColor(.Mark.nutzerBot)
        case .systemBot:           .Mark.dot.withTintColor(.Mark.systemBot)
        case .ehemaligerHelfer:    .Mark.dot.withTintColor(.Mark.ehemaligerHelfer)
        case .unbekannt:           .Mark.dot.withTintColor(.gray)
        }
    }
}
