
import UIKit

class OPLabel: UILabel {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setup()
    }
        
    private func setup() {
        layer.cornerRadius = 5
        backgroundColor = #colorLiteral(red: 0.9333333333, green: 0.3019607843, blue: 0.1803921569, alpha: 1)
        clipsToBounds = true
    }
}
