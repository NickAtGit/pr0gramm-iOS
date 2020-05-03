
import UIKit

protocol Theme {
    var tint: UIColor { get }
    
    var backgroundColor: UIColor { get }
    var separatorColor: UIColor { get }
    var selectionColor: UIColor { get }
    
    var labelColor: UIColor { get }
    var secondaryLabelColor: UIColor { get }
    var subtleLabelColor: UIColor { get }
    
    var barStyle: UIBarStyle { get }
    func apply(for application: UIApplication)
}

struct AngenehmesGruenTheme: Theme {
    let tint: UIColor = Appearance.angenehmesGruen
    
    let backgroundColor: UIColor = #colorLiteral(red: 0.0862745098, green: 0.0862745098, blue: 0.09411764706, alpha: 1)
    let separatorColor: UIColor = Appearance.angenehmesGruen
    let selectionColor: UIColor = .init(red: 38/255, green: 38/255, blue: 40/255, alpha: 1)
    
    let labelColor: UIColor = #colorLiteral(red: 0.9490196078, green: 0.9607843137, blue: 0.9568627451, alpha: 1)
    let secondaryLabelColor: UIColor = .lightGray
    let subtleLabelColor: UIColor = .darkGray
    
    let barStyle: UIBarStyle = .black
}

struct OrangeTheme: Theme {
    let tint: UIColor = Appearance.orange
    
    let backgroundColor: UIColor = #colorLiteral(red: 0.0862745098, green: 0.0862745098, blue: 0.09411764706, alpha: 1)
    let separatorColor: UIColor = Appearance.orange
    let selectionColor: UIColor = .init(red: 38/255, green: 38/255, blue: 40/255, alpha: 1)
    
    let labelColor: UIColor = #colorLiteral(red: 0.9490196078, green: 0.9607843137, blue: 0.9568627451, alpha: 1)
    let secondaryLabelColor: UIColor = .lightGray
    let subtleLabelColor: UIColor = .darkGray
    
    let barStyle: UIBarStyle = .black
}

struct MegaEpischesBlau: Theme {
    let tint: UIColor = Appearance.megaEpischesBlau
    
    let backgroundColor: UIColor = #colorLiteral(red: 0.0862745098, green: 0.0862745098, blue: 0.09411764706, alpha: 1)
    let separatorColor: UIColor = Appearance.megaEpischesBlau
    let selectionColor: UIColor = .init(red: 38/255, green: 38/255, blue: 40/255, alpha: 1)
    
    let labelColor: UIColor = #colorLiteral(red: 0.9490196078, green: 0.9607843137, blue: 0.9568627451, alpha: 1)
    let secondaryLabelColor: UIColor = .lightGray
    let subtleLabelColor: UIColor = .darkGray
    
    let barStyle: UIBarStyle = .black
}

struct PinkTheme: Theme {
    let tint: UIColor = Appearance.pink
    
    let backgroundColor: UIColor = #colorLiteral(red: 0.0862745098, green: 0.0862745098, blue: 0.09411764706, alpha: 1)
    let separatorColor: UIColor = Appearance.pink
    let selectionColor: UIColor = .init(red: 38/255, green: 38/255, blue: 40/255, alpha: 1)
    
    let labelColor: UIColor = #colorLiteral(red: 0.9490196078, green: 0.9607843137, blue: 0.9568627451, alpha: 1)
    let secondaryLabelColor: UIColor = .lightGray
    let subtleLabelColor: UIColor = .darkGray
    
    let barStyle: UIBarStyle = .black
}

struct YellowTheme: Theme {
    let tint: UIColor = Appearance.yellow
    
    let backgroundColor: UIColor = #colorLiteral(red: 0.0862745098, green: 0.0862745098, blue: 0.09411764706, alpha: 1)
    let separatorColor: UIColor = Appearance.yellow
    let selectionColor: UIColor = .init(red: 38/255, green: 38/255, blue: 40/255, alpha: 1)
    
    let labelColor: UIColor = #colorLiteral(red: 0.9490196078, green: 0.9607843137, blue: 0.9568627451, alpha: 1)
    let secondaryLabelColor: UIColor = .lightGray
    let subtleLabelColor: UIColor = .darkGray
    
    let barStyle: UIBarStyle = .black
}

class Theming {
    static func applySelectedPersistedTheme() {
        let theme: Theme
        
        switch AppSettings.selectedTheme {
        case 0: theme = MegaEpischesBlau()
        case 1: theme = OrangeTheme()
        case 2: theme = AngenehmesGruenTheme()
        case 3: theme = PinkTheme()
        case 4: theme = YellowTheme()
        default: theme = MegaEpischesBlau()
        }
        theme.apply(for: UIApplication.shared)
    }
}


extension Theme {
    
    func apply(for application: UIApplication) {
        application.keyWindow?.tintColor = tint
        
        let font15 = UIFont.systemFont(ofSize: 15)
        let font12 =  UIFont.systemFont(ofSize: 12)

        UIBarButtonItem.appearance().setTitleTextAttributes([NSAttributedString.Key.font: font15],
                                                            for: .normal)
        UIBarButtonItem.appearance().setTitleTextAttributes([NSAttributedString.Key.font: font15],
                                                            for: .disabled)
        UIBarButtonItem.appearance().setTitleTextAttributes([NSAttributedString.Key.font: font15],
                                                            for: .highlighted)
        
        UITabBarItem.appearance().setTitleTextAttributes([.font: font12],
                                                         for: .normal)
        
        UISegmentedControl.appearance().setTitleTextAttributes([.font: font12], for: .normal)
        
        UITextView.appearance().with {
            $0.textColor = labelColor
            $0.font = font15
        }
        
        UITextField.appearance().with {
            $0.font = font15
        }
        
        UITabBar.appearance().with {
            $0.tintColor = tint
            $0.isTranslucent = false
            $0.barTintColor = #colorLiteral(red: 0.0862745098, green: 0.0862745098, blue: 0.09411764706, alpha: 1)
        }
        
        UINavigationBar.appearance().with {
            $0.tintColor = tint
            $0.shadowImage = tint.as1ptImage()
            $0.titleTextAttributes = [.foregroundColor: labelColor,
                                      .font: UIFont.systemFont(ofSize: 17, weight: .bold)]
            $0.isTranslucent = false
            $0.barTintColor = #colorLiteral(red: 0.0862745098, green: 0.0862745098, blue: 0.09411764706, alpha: 1)
        }
        
        UISearchTextField.appearance().with {
            $0.textColor = labelColor
        }
        
        UICollectionView.appearance().backgroundColor = backgroundColor
        
        UITableView.appearance().with {
            $0.backgroundColor = backgroundColor
            $0.separatorColor = separatorColor
        }
        
        UITableViewCell.appearance().with {
            $0.backgroundColor = .clear
        }
                
        UIButton.appearance().with {
            $0.setTitleColor(tint, for: .normal)
        }
        
        UIImageView.appearance().with {
            $0.tintColor = tint
        }
        
        UISegmentedControl.appearance().with {
            $0.setTitleTextAttributes([.font: font12,
                                       .foregroundColor: #colorLiteral(red: 0.9490196078, green: 0.9607843137, blue: 0.9568627451, alpha: 1)], for: .normal)
            $0.backgroundColor = tint
            $0.selectedSegmentTintColor = backgroundColor
        }
        
        application.windows.reload()
    }
}

extension UIColor {

    /// Converts this `UIColor` instance to a 1x1 `UIImage` instance and returns it.
    ///
    /// - Returns: `self` as a 1x1 `UIImage`.
    func as1ptImage() -> UIImage {
        UIGraphicsBeginImageContext(CGSize(width: 1, height: 2))
        setFill()
        UIGraphicsGetCurrentContext()?.fill(CGRect(x: 0, y: 0, width: 1, height: 2))
        let image = UIGraphicsGetImageFromCurrentImageContext() ?? UIImage()
        UIGraphicsEndImageContext()
        return image
    }
}
