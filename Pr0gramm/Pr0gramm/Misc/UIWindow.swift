
import UIKit

public extension UIWindow {
    
    func reload() {
        subviews.forEach { view in
            view.removeFromSuperview()
            addSubview(view)
        }
    }
}

public extension Array where Element == UIWindow {
    
    func reload() {
        forEach { $0.reload() }
    }
}
