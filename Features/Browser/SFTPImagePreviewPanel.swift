/*
 * Copyright (c) 2003 Regents of The University of Michigan.
 * All Rights Reserved.  See COPYRIGHT.
 */

import AppKit

/// Image preview panel. Zooms from the clicked cell to the saved panel frame.
@objc(SFTPImagePreviewPanel)
final class SFTPImagePreviewPanel: NSPanel {
    override func animationResizeTime(_ newFrame: NSRect) -> TimeInterval {
        0.25
    }

    @objc(zoomFromRect:toRect:)
    func zoom(from originRect: NSRect, to destRect: NSRect) {
        setFrame(originRect, display: false, animate: false)
        makeKeyAndOrderFront(nil)
        setFrame(destRect, display: true, animate: true)
    }
}
