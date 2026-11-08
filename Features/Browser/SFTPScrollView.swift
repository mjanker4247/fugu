import AppKit

/// Draws the focus ring around the active table. Same rules as the old `SFTPScrollView`.
@objc(SFTPScrollView)
final class SFTPScrollView: NSScrollView {
    private var shouldDrawFocusRing = false
    private var last: NSResponder?

    override var needsDisplay: Bool {
        get {
            var responder: NSResponder?
            if window?.isKeyWindow == true {
                responder = window?.firstResponder
                if responder === last {
                    return super.needsDisplay
                }
            } else if last == nil {
                return super.needsDisplay
            }

            shouldDrawFocusRing = responder is NSView && (responder as? NSView)?.isDescendant(of: self) == true
            last = responder
            setKeyboardFocusRingNeedsDisplay(bounds)
            return true
        }
        set {
            super.needsDisplay = newValue
        }
    }

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        if shouldDrawFocusRing {
            NSFocusRingPlacement.only.set()
            bounds.fill()
        }
    }
}
