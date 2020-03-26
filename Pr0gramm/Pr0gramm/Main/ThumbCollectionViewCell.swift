
import UIKit

class ThumbCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet var imageView: UIImageView!
    
    override func prepareForReuse() {
        imageView.image = nil
    }
}
