
import UIKit

class TapableImageView: UIImageView {
    
    let nc = NotificationCenter.default
    let feedback = UISelectionFeedbackGenerator()

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let location = touches.first?.location(in: self) else { return }

        let touchAreaWidth: CGFloat = 80

        if location.x <= touchAreaWidth {
            print("Left area touched")
            nc.post(name: Notification.Name("leftTapped"), object: nil)
            feedback.selectionChanged()
        } else if location.x >= (self.frame.size.width - touchAreaWidth) {
            print("Right area touched")
            nc.post(name: Notification.Name("rightTapped"), object: nil)
            feedback.selectionChanged()
        } else {
            print("Ignore in-between touch.")
        }
    }

}
