
import UIKit
import AVKit
 
class TapableImageView: UIImageView {
    
    private let nc = NotificationCenter.default
    private let feedback = UISelectionFeedbackGenerator()

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let location = touches.first?.location(in: self) else { return }

        let touchAreaWidth: CGFloat = 80

        if location.x <= touchAreaWidth {
            nc.post(name: Notification.Name("leftTapped"), object: nil)
            feedback.selectionChanged()
        } else if location.x >= (self.frame.size.width - touchAreaWidth) {
            nc.post(name: Notification.Name("rightTapped"), object: nil)
            feedback.selectionChanged()
        } else {
            nc.post(name: Notification.Name("showImageDetail"), object: self)
        }
    }

}

class TapableAVPlayerViewController: AVPlayerViewController {
    
    private let nc = NotificationCenter.default
    private let feedback = UISelectionFeedbackGenerator()

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let location = touches.first?.location(in: view) else { return }

        let touchAreaWidth: CGFloat = 80

        if location.x <= touchAreaWidth {
            nc.post(name: Notification.Name("leftTapped"), object: nil)
            feedback.selectionChanged()
        } else if location.x >= (view.frame.size.width - touchAreaWidth) {
            nc.post(name: Notification.Name("rightTapped"), object: nil)
            feedback.selectionChanged()
        }
    }
}
