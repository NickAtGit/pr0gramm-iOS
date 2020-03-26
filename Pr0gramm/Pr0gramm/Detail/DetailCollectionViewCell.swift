
import UIKit

class DetailCollectionViewCell: UICollectionViewCell {

    var item: Item!
    @IBOutlet var content: UIView!

    var detailViewController: DetailViewController!
    
    override func prepareForReuse() {
        content.subviews.forEach {
            if $0.superview == content {
                $0.removeFromSuperview()
            }
        }
        
        guard let detailViewController = detailViewController else { return }
        detailViewController.willMove(toParent: nil)
        detailViewController.view.removeFromSuperview()
        detailViewController.removeFromParent()
    }
}
