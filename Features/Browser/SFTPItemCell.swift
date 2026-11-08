/*
 *
 * subclass of NSTextFieldCell that shows image and text. Based on
 * Apple's sample code for ImageAndTextCell in DragAndDropOutlineView.
 *
 */

import AppKit

/// Name-column cell. Draws a 16-point icon beside the text, vertically centered.
@objc(SFTPItemCell)
final class SFTPItemCell: NSTextFieldCell {
    private var itemImage: NSImage?

    override func copy(with zone: NSZone? = nil) -> Any {
        let cell = super.copy(with: zone) as! SFTPItemCell
        cell.itemImage = itemImage
        return cell
    }

    @objc func italicizeStringValue() {
        let value = stringValue
        let range = (value as NSString).range(of: value)
        let index = range.location
        if index == NSNotFound {
            NSLog("not found")
            return
        }

        let manager = NSFontManager.shared
        let attributed = NSMutableAttributedString()
        attributed.setAttributedString(attributedStringValue)
        var cursor = index
        while NSLocationInRange(cursor, range) {
            let base = NSFont(name: "Helvetica", size: 12) ?? NSFont.systemFont(ofSize: 12)
            let italic = NSFontTraitMask(rawValue: 0x00000001)
            let font = manager.convert(base, toHaveTrait: italic)
            attributed.addAttribute(.font, value: font, range: range)
            cursor = NSMaxRange(range)
        }
        attributedStringValue = attributed
    }

    override var image: NSImage? {
        get { itemImage }
        set {
            if newValue !== itemImage {
                itemImage = newValue
            }
        }
    }

    override func edit(withFrame aRect: NSRect, in controlView: NSView, editor textObj: NSText, delegate: Any?, event: NSEvent?) {
        var imageFrame = NSRect.zero
        var textFrame = NSRect.zero
        NSDivideRect(aRect, &imageFrame, &textFrame, (itemImage?.size.width ?? 0) + 1, .minX)
        super.edit(withFrame: textFrame, in: controlView, editor: textObj, delegate: delegate, event: event)
    }

    override func select(withFrame aRect: NSRect, in controlView: NSView, editor textObj: NSText, delegate: Any?, start selStart: Int, length selLength: Int) {
        var imageFrame = NSRect.zero
        var textFrame = NSRect.zero
        NSDivideRect(aRect, &imageFrame, &textFrame, (itemImage?.size.width ?? 0) + 1, .minX)
        super.select(withFrame: textFrame, in: controlView, editor: textObj, delegate: delegate, start: selStart, length: selLength)
    }

    override func draw(withFrame cellFrame: NSRect, in controlView: NSView) {
        var remainder = cellFrame
        if let itemImage {
            var imageSize = itemImage.size
            if imageSize.width > 16 {
                imageSize.width = 16
            }
            if imageSize.height > 16 {
                imageSize.height = 16
            }
            if imageSize.width < 1 || imageSize.height < 1 {
                imageSize = NSSize(width: 16, height: 16)
            }
            var imageFrame = NSRect.zero
            NSDivideRect(remainder, &imageFrame, &remainder, imageSize.width + 1, .minX)
            imageFrame.origin.x += 1
            imageFrame.size = imageSize
            imageFrame.origin.y += ceil((remainder.size.height - imageFrame.size.height) / 2)
            itemImage.draw(in: imageFrame, from: .zero, operation: .sourceOver, fraction: 1, respectFlipped: true, hints: nil)
        }
        super.draw(withFrame: remainder, in: controlView)
    }

    override var cellSize: NSSize {
        var size = super.cellSize
        size.width += (itemImage?.size.width ?? 0) + 1
        return size
    }
}
