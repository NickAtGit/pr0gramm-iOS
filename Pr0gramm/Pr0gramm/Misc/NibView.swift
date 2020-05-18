
import UIKit

public protocol NibView: AnyObject {
    static func fromNib() -> Self
    static var nibName: String { get }
    static var nib: UINib { get }
}

public extension NibView {

    static func fromNib() -> Self {
        let views = Bundle(for: Self.self).loadNibNamed(nibName, owner: nil, options: nil)
        return views![0] as! Self
    }

    static var nibName: String {
        return String(describing: self)
    }

    static var nib: UINib {
        return UINib(nibName: nibName, bundle: Bundle(for: self))
    }
}
