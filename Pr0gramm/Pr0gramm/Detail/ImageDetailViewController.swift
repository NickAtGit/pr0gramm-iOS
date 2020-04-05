
import UIKit
import ImageScrollView

class ImageDetailViewController: UIViewController, StoryboardInitialViewController {
    
    @IBOutlet var imageScrollView: ImageScrollView!
    
    var image: UIImage?
        
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        imageScrollView.setup()
        guard let image = image else { return }
        imageScrollView.display(image: image)
    }
}
