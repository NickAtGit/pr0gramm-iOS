/**
 *  GTForceTouchGestureRecognizerInternal
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

internal extension GTForceTouchGestureRecognizer {
    
    internal func handleTouch(_ touch: UITouch?) {
        guard view != nil, let touch = touch, touch.force != 0 && touch.maximumPossibleForce != 0 else {
            return
        }
        let forcePercentage = touch.force / touch.maximumPossibleForce
        if deepPressed && forcePercentage <= 0 {
            state = UIGestureRecognizer.State.ended
            return
        }
        handleForceTouch(with: forcePercentage)
    }
    
    private func handleForceTouch(with forcePercentage: CGFloat) {
        let currentTime = NSDate.timeIntervalSinceReferenceDate
        if !deepPressed && forcePercentage >= threshold {
            deepPressed = true
            state = UIGestureRecognizer.State.began
            return
        }
        if deepPressed && currentTime - deepPressedAt > hardTriggerMinTime && forcePercentage == 1.0 {
            state = UIGestureRecognizer.State.ended
        }
    }
}
