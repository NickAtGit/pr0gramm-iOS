
import UIKit
import AVKit
import Kingfisher
 
extension Notification.Name {
    static let leftTapped = Notification.Name(rawValue: "leftTapped")
    static let rightTapped = Notification.Name(rawValue: "rightTapped")
    static let doubleTapped = Notification.Name(rawValue: "doubleTapped")
}

class TapableImageView: AnimatedImageView, SeenBadgeShowable, StickyBadgeShowable {
    var badgeView: UIView?
    var stickyBadgeView: UIView?
    private let nc = NotificationCenter.default
    private let feedback = UISelectionFeedbackGenerator()
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        //Killed setting for left right tap because of issues, this code below should be deleted
        guard let location = touches.first?.location(in: self),
            false else { return }

        let touchAreaWidth: CGFloat = 80

        if location.x <= touchAreaWidth {
            nc.post(name: Notification.Name.leftTapped, object: nil)
            feedback.selectionChanged()
        } else if location.x >= (frame.size.width - touchAreaWidth) {
            nc.post(name: Notification.Name.rightTapped, object: nil)
            feedback.selectionChanged()
        }
    }
}

class TapableAVPlayerViewController: AVPlayerViewController, SeenBadgeShowable, StickyBadgeShowable {
    var badgeView: UIView?
    var stickyBadgeView: UIView?
    private let nc = NotificationCenter.default
    private let feedback = UISelectionFeedbackGenerator()
        
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        //Killed setting for left right tap because of issues, this code below should be deleted
        guard let location = touches.first?.location(in: view),
              false else { return }

        let touchAreaWidth: CGFloat = 80

        if location.x <= touchAreaWidth {
            nc.post(name: Notification.Name.leftTapped, object: nil)
            feedback.selectionChanged()
        } else if location.x >= (view.frame.size.width - touchAreaWidth) {
            nc.post(name: Notification.Name.rightTapped, object: nil)
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
