
import UIKit

class InfoView: UIView, NibView {
    
    @IBOutlet var pointsLabel: UILabel!
    @IBOutlet var userNameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = .clear
        pointsLabel.textColor = .white
        userNameLabel.textColor = .white
    }
}
