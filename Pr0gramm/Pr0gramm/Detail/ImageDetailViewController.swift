
import UIKit
import ImageScrollView

class ImageDetailViewController: UIViewController, Storyboarded {
    
    @IBOutlet var imageScrollView: ImageScrollView!
    var image: UIImage?
    
    private var initalZoomScale: CGFloat = 1.0
        
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = #colorLiteral(red: 0.0862745098, green: 0.0862745098, blue: 0.09411764706, alpha: 1)
        imageScrollView.backgroundColor = #colorLiteral(red: 0.0862745098, green: 0.0862745098, blue: 0.09411764706, alpha: 1)
        imageScrollView.setup()
        guard let image = image else { return }
        imageScrollView.display(image: image)
        imageScrollView.imageScrollViewDelegate = self
        initalZoomScale = imageScrollView.zoomScale
    }
}

extension ImageDetailViewController: ImageScrollViewDelegate {
    func imageScrollViewDidChangeOrientation(imageScrollView: ImageScrollView) {}
        
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        let threshold: CGFloat = UIDevice.current.userInterfaceIdiom == UIUserInterfaceIdiom.pad ? 0.3 : 0.1
        
        if scrollView.zoomScale < initalZoomScale - threshold {
            dismiss(animated: true)
        }
    }
}
