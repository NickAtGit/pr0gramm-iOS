
import UIKit
import AVKit
 
class TapableImageView: UIImageView, SeenBadgeShowable {
    var badgeView: UIView?
    private let nc = NotificationCenter.default
    private let feedback = UISelectionFeedbackGenerator()

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let location = touches.first?.location(in: self),
            AppSettings.isUseLeftRightQuickTap else { return }

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

class TapableAVPlayerViewController: AVPlayerViewController, SeenBadgeShowable {
    var badgeView: UIView?
    private let nc = NotificationCenter.default
    private let feedback = UISelectionFeedbackGenerator()

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let location = touches.first?.location(in: view),
            AppSettings.isUseLeftRightQuickTap else { return }

        let touchAreaWidth: CGFloat = 80

        if location.x <= touchAreaWidth {
            nc.post(name: Notification.Name("leftTapped"), object: nil)
            feedback.selectionChanged()
        } else if location.x >= (view.frame.size.width - touchAreaWidth) {
            nc.post(name: Notification.Name("rightTapped"), object: nil)
            feedback.selectionChanged()
        }
    }
    
    func goFullScreen() {
        let selectorName = "enterFullScreenAnimated:completionHandler:"
        let selectorToForceFullScreenMode = NSSelectorFromString(selectorName)

        if self.responds(to: selectorToForceFullScreenMode) {
            self.perform(selectorToForceFullScreenMode, with: true, with: nil)
        }
    }

    func quitFullScreen() {
        let selectorName = "exitFullScreenAnimated:completionHandler:"
        let selectorToForceQuitFullScreenMode = NSSelectorFromString(selectorName)

        if self.responds(to: selectorToForceQuitFullScreenMode) {
            self.perform(selectorToForceQuitFullScreenMode, with: true, with: nil)
        }
    }
}
