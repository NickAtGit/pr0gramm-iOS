
import UIKit
import ImageScrollView

class ImageDetailViewController: UIViewController, StoryboardInitialViewController {
    
    @IBOutlet var imageScrollView: ImageScrollView!
    
    var image: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imageScrollView.setup()
        guard let image = image else { return }
        imageScrollView.display(image: image)
    }
}
