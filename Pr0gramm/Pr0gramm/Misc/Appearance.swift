
import UIKit

class Appearance {
    
    static let orange = UIColor(red: 238/255, green: 77/255, blue: 46/255, alpha: 1.0)
    static let angenehmesGruen = UIColor(red: 29/255, green: 185/255, blue: 146/255, alpha: 1)
    static let megaEpischesBlau = UIColor(red: 0, green: 143/255, blue: 1, alpha: 1)
    static let pink = UIColor(red: 1, green: 0, blue: 130/255, alpha: 1)
    static let yellow = UIColor(red: 252/255, green: 209/255, blue: 42/255, alpha: 1)

    static let themeColor = Appearance.angenehmesGruen
    static let standardCornerRadius: CGFloat = 12
    
    static func getScaledFont(forFont name: String, textStyle: UIFont.TextStyle) -> UIFont {
        
        /// Uncomment the code below to check all the available fonts and have them printed in the console to double check the font name with existing fonts 😉
        
        /*for family: String in UIFont.familyNames
         {
         print("\(family)")
         for names: String in UIFont.fontNames(forFamilyName: family)
         {
         print("== \(names)")
         }
         }*/
        
        let userFont =  UIFontDescriptor.preferredFontDescriptor(withTextStyle: textStyle)
        let pointSize = userFont.pointSize
        guard let customFont = UIFont(name: name, size: pointSize) else { fatalError() }
        return UIFontMetrics.default.scaledFont(for: customFont)
    }
}

