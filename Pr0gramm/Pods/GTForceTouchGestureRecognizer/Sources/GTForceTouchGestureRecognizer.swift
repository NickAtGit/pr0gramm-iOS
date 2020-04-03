/**
 *  GTForceTouchGestureRecognizer
 *
 *  Copyright (c) 2018 Giuseppe Travasoni. Licensed under the MIT license, as follows:
 *
 *  Permission is hereby granted, free of charge, to any person obtaining a copy
 *  of this software and associated documentation files (the "Software"), to deal
 *  in the Software without restriction, including without limitation the rights
 *  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 *  copies of the Software, and to permit persons to whom the Software is
 *  furnished to do so, subject to the following conditions:
 *
 *  The above copyright notice and this permission notice shall be included in all
 *  copies or substantial portions of the Software.
 *
 *  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 *  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 *  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 *  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 *  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 *  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 *  SOFTWARE.
 */

import UIKit.UIGestureRecognizerSubclass

/// Force touch gesture recognizer
public class GTForceTouchGestureRecognizer: UIGestureRecognizer {
    
    internal var deepPressedAt: TimeInterval = 0
    internal var gestureParameters: (target: AnyObject?, action: Selector)
    internal var hardTriggerMinTime: TimeInterval
    internal let feedbackGenerator = UIImpactFeedbackGenerator.init(style: .medium)
    internal let threshold: CGFloat
    
    internal var deepPressed: Bool = false {
        didSet {
            guard deepPressed, !oldValue else {
                return
            }
            deepPressedAt = NSDate.timeIntervalSinceReferenceDate
        }
    }
    
    /// The current state of the gesture recognizer
    public override var state: UIGestureRecognizer.State {
        didSet {
            guard oldValue != state else {
                return
            }
            switch state {
            case .began:
                feedbackGenerator.prepare()
            case .ended:
                feedbackGenerator.impactOccurred()
                _ = gestureParameters.target?.perform(gestureParameters.action, with: self)
            default:
                return
            }
        }
    }
    
    /**
     Initialize a force touch gesture recognizer.
     - Parameters:
        - target: target object on which call the selector
        - action: selector to perform on target object
        - threshold: minimum percentage force value to validate touch (default 0.75)
        - hardTriggerMinTime: minumum time over threshold percentage to validate touch (default 0.5)
     */
    required public init(target: AnyObject?, action: Selector, threshold: CGFloat = 0.75, hardTriggerMinTime: TimeInterval = 0.5) {
        self.gestureParameters = (target, action)
        self.threshold = threshold
        self.hardTriggerMinTime = hardTriggerMinTime
        super.init(target: nil, action: nil)
    }
    
    override public func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent) {
        handleTouch(touches.first)
    }
    
    override public func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent) {
        handleTouch(touches.first)
    }
    
    override public func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent) {
        state = deepPressed ? UIGestureRecognizer.State.ended : UIGestureRecognizer.State.failed
        deepPressed = false
        super.touchesEnded(touches, with: event)
    }
}
