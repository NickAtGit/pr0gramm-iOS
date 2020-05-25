
import UIKit

enum BadgeStyle {
    case op, you
}

class BadgeLabel: UILabel {
    
    var style: BadgeStyle? {
        didSet {
            guard let style = style else { return }
            setup(with: style)
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setup(with: .op)
    }
        
    private func setup(with style: BadgeStyle) {
        layer.cornerRadius = 5
        clipsToBounds = true

        switch style {
        case .op:
            backgroundColor = #colorLiteral(red: 0.9333333333, green: 0.3019607843, blue: 0.1803921569, alpha: 1)
        case .you:
            backgroundColor = #colorLiteral(red: 0.3411764801, green: 0.6235294342, blue: 0.1686274558, alpha: 1)
        }
    }
}
