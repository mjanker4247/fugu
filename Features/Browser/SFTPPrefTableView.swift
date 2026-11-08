/*
 * Copyright (c) 2005 Regents of The University of Michigan.
 * All Rights Reserved.  See COPYRIGHT.
 */

import AppKit

/// Favorites and known-hosts tables. Stripes odd rows and keeps Return from moving to the next cell.
@objc(SFTPPrefTableView)
final class SFTPPrefTableView: NSTableView {
    private static var stripeColor: NSColor?

    override func awakeFromNib() {
        super.awakeFromNib()
        let cell = NSTextFieldCell()
        cell.drawsBackground = false
        cell.isEditable = true
        for column in tableColumns {
            column.dataCell = cell
        }
    }

    private func drawStripes(in rect: NSRect) {
        let fullRowHeight = rowHeight + intercellSpacing.height
        if fullRowHeight == 0 {
            return
        }
        let clipBottom = rect.maxY
        var firstStripe = Int(rect.origin.y / fullRowHeight)
        if firstStripe % 2 != 0 {
            firstStripe += 1
        }

        var stripeRect = NSRect.zero
        stripeRect.origin.x = rect.origin.x
        stripeRect.origin.y = CGFloat(firstStripe) * fullRowHeight
        stripeRect.size.width = rect.size.width
        stripeRect.size.height = fullRowHeight

        if SFTPPrefTableView.stripeColor == nil {
            SFTPPrefTableView.stripeColor = NSColor(
                calibratedRed: 237.0 / 255.0,
                green: 243.0 / 255.0,
                blue: 254.0 / 255.0,
                alpha: 1
            )
        }
        SFTPPrefTableView.stripeColor?.setFill()

        while stripeRect.origin.y < clipBottom {
            stripeRect.fill()
            stripeRect.origin.y += fullRowHeight * 2
        }
    }

    override func highlightSelection(inClipRect rect: NSRect) {
        drawStripes(in: rect)
        super.highlightSelection(inClipRect: rect)
    }

    override func textDidEndEditing(_ notification: Notification) {
        let movement = (notification.userInfo?["NSTextMovement"] as? NSNumber)?.intValue ?? 0
        var forwarded = notification
        if movement == NSTextMovement.return.rawValue {
            var info = notification.userInfo ?? [:]
            info["NSTextMovement"] = NSNumber(value: NSTextMovement.other.rawValue)
            forwarded = Notification(name: notification.name, object: notification.object, userInfo: info)
        }
        super.textDidEndEditing(forwarded)
        if movement != NSTextMovement.tab.rawValue {
            window?.makeFirstResponder(self)
        }
    }
}
