
import UIKit

class TagCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet var tagLabel: UILabel!
    @IBOutlet var containerView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        containerView.backgroundColor = #colorLiteral(red: 0.1647058824, green: 0.1803921569, blue: 0.1921568627, alpha: 1)
        containerView.layer.cornerRadius = tagLabel.intrinsicContentSize.height / 2
        containerView.clipsToBounds = true
        tagLabel.textColor = .white
    }
}
