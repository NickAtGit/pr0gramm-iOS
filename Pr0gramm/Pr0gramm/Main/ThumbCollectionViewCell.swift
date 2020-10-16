
import UIKit

class ThumbCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet var imageView: ThumbImageView!
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
        imageView.subviews.forEach { $0.removeFromSuperview() }
        imageView.badgeView = nil
    }
}

class ThumbImageView: UIImageView, SeenBadgeShowable {
    var badgeView: UIView?
}
