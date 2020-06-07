
import UIKit

@IBDesignable
class UserClassDotView: UIView {
    
    override func layoutSubviews() {
        layer.cornerRadius = bounds.width / 2
    }
    
    override func prepareForInterfaceBuilder() {
        backgroundColor = Colors.altschwuchtel
    }
}
