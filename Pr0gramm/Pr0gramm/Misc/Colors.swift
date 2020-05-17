
import UIKit

struct Colors {
    
    static let schwuchtel = UIColor(rgb: 0xffffff)
    static let neuschwuchtel = UIColor(rgb: 0xe108e9)
    static let altschwuchtel = UIColor(rgb: 0x5bb91c)
    static let admin = UIColor(rgb: 0xff9900)
    static let gesperrt = UIColor(rgb: 0x444444)
    static let moderator = UIColor(rgb: 0x008FFF)
    static let fliesentischbesitzer = UIColor(rgb: 0x6C432B)
    static let lebendeLegende = UIColor(rgb: 0x1cb992)
    static let wichtel = UIColor(rgb: 0xd23c22)
    static let edlerSpender = UIColor(rgb: 0x1cb992)
    static let mittelAltSchwuchtel = UIColor(rgb: 0xaddc8d)
    static let altModerator = UIColor(rgb: 0x7fc7ff)
    static let communityHelfer = UIColor(rgb: 0xc52b2f)
    static let nutzerBot = UIColor(rgb: 0x10366f)
    static let systemBot = UIColor(rgb: 0xffc166)

    static func color(for mark: Int) -> UIColor {
        switch mark {
        case 0: return Colors.schwuchtel
        case 1: return Colors.neuschwuchtel
        case 2: return Colors.altschwuchtel
        case 3: return Colors.admin
        case 4: return Colors.gesperrt
        case 5: return Colors.moderator
        case 6: return Colors.fliesentischbesitzer
        case 7: return Colors.lebendeLegende
        case 8: return Colors.wichtel
        case 9: return Colors.edlerSpender
        case 10: return Colors.mittelAltSchwuchtel
        case 11: return Colors.altModerator
        case 12: return Colors.communityHelfer
        case 13: return Colors.nutzerBot
        case 14: return Colors.systemBot
        default: return Colors.schwuchtel
        }
    }
}

extension UIColor {
    convenience init(red: Int, green: Int, blue: Int) {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")
        
        self.init(red: CGFloat(red)/255.0, green: CGFloat(green)/255.0, blue: CGFloat(blue)/255.0, alpha: 1.0)
    }
    
    convenience init(rgb: Int) {
        self.init( red: (rgb >> 16) & 0xFF, green: (rgb >> 8) & 0xFF, blue: rgb & 0xFF)
    }
}
