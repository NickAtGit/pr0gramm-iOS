
import UIKit

class HapticFeedbackButton: UIButton {
    
    private let feedback = UISelectionFeedbackGenerator()
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        feedback.prepare()
        feedback.selectionChanged()
    }
}
