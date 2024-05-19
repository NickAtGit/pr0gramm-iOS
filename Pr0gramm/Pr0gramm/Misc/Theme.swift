
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
        default: theme = OrangeTheme()
        }
        theme.apply(for: UIApplication.shared)
    }
}


extension Theme {
    
    func apply(for application: UIApplication) {
        application.connectedScenes.compactMap { ($0 as? UIWindowScene)?.keyWindow }.last?
        .tintColor = tint
        
        let font15 = UIFont.systemFont(ofSize: 15)
        let font12 =  UIFont.systemFont(ofSize: 12)
        let font10 =  UIFont.systemFont(ofSize: 10)

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
        
        // Prevent theming of text in the keyboard shortcut discovery overlay (appearing when holding the Command key)
        // TODO: The overlay class should be more specific, but I can't find any resource about the name or class of this system overlay.
        // TODO: Maybe it is a wise idea to scrap the global styling of UITextViews altogether because of the side-effects.
        UITextView.appearance(whenContainedInInstancesOf: [UIVisualEffectView.self]).with {
            $0.textColor = nil
            $0.font = nil
        }
        
        UITextField.appearance().with {
            $0.font = font15
        }
                
        UINavigationBar.appearance().with {
            let app = UINavigationBarAppearance()
            app.configureWithOpaqueBackground()
            app.shadowImage = tint.as1ptImage()
            app.titleTextAttributes = [.foregroundColor: labelColor,
                                       .font: UIFont.systemFont(ofSize: 17, weight: .bold)]
            
            let barButtonItemAppearance = UIBarButtonItemAppearance()
            barButtonItemAppearance.normal.titleTextAttributes = [.font: font15]
            app.buttonAppearance = barButtonItemAppearance
            
            $0.standardAppearance = app
            $0.scrollEdgeAppearance = app
            $0.tintColor = tint
        }
        
        UITabBar.appearance().with {
            let app = UITabBarAppearance()
            app.configureWithOpaqueBackground()
            $0.tintColor = tint
            
            let tabBarItemAppearance = UITabBarItemAppearance()
            tabBarItemAppearance.normal.titleTextAttributes = [.font: font12]
            tabBarItemAppearance.selected.titleTextAttributes = [.font: font12]
            app.inlineLayoutAppearance = tabBarItemAppearance
            
            let compactInlineItemAppearance = UITabBarItemAppearance()
            compactInlineItemAppearance.normal.titleTextAttributes = [.font: font10]
            compactInlineItemAppearance.selected.titleTextAttributes = [.font: font10]
            app.compactInlineLayoutAppearance = compactInlineItemAppearance
            app.stackedLayoutAppearance = compactInlineItemAppearance

            $0.standardAppearance = app
            
            if #available(iOS 15.0, *) {
                $0.scrollEdgeAppearance = app
            }
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
            $0.selectedBackgroundView = UIView()
            $0.selectedBackgroundView?.backgroundColor = tint.withAlphaComponent(0.2)
        }
                
        UIButton.appearance().with {
            $0.setTitleColor(tint, for: .normal)
        }
        
        UIImageView.appearance().with {
            $0.tintColor = tint
        }
        
        // Prevent theming of text containing icons in the keyboard shortcut discovery overlay (appearing when holding the Command key)
        // TODO: The overlay class should be more specific, but I can't find any resource about the name or class of this system overlay.
        // TODO: Maybe it is a wise idea to scrap the global styling of UIImageView altogether because of the side-effects.
        UIImageView.appearance(whenContainedInInstancesOf: [UIVisualEffectView.self]).with {
            $0.tintColor = nil
        }
        
        UISegmentedControl.appearance().with {
            $0.setTitleTextAttributes([.font: font12,
                                       .foregroundColor: #colorLiteral(red: 0.9490196078, green: 0.9607843137, blue: 0.9568627451, alpha: 1)], for: .normal)
            $0.backgroundColor = tint
            $0.selectedSegmentTintColor = backgroundColor
        }
        
        SeparatorView.appearance().with {
            $0.backgroundColor = tint
        }
        
        UIRefreshControl.appearance().with {
            $0.tintColor = tint
        }
        
        NavigationBannerView.appearance().with {
            $0.backgroundColor = tint
        }
        
        UISlider.appearance().with {
            $0.thumbTintColor = tint
        }
        
        application.connectedScenes.compactMap { ($0 as? UIWindowScene)?.windows }.last?
        .reload()
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
