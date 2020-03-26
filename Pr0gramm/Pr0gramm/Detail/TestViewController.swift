
import UIKit

class TestViewController: UIViewController, StoryboardInitialViewController {
    
    var item: Item?
    var pr0grammConnector: Pr0grammConnector!
    @IBOutlet var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let item = item else { return }
        
        if let link = pr0grammConnector.imageLink(for: item) {
            imageView.downloadedFrom(link: link)
        } 
    }
}
