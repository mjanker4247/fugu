/*
 * Copyright (c) 2003 Regents of The University of Michigan.
 * All Rights Reserved.  See COPYRIGHT.
 */

import AppKit

/// Preview image. A mouse-down starts a drag of the image, and of the file URL when one is set.
@objc(SFTPImageView)
final class SFTPImageView: NSImageView, NSDraggingSource {
    private var storedLocationPath: String?

    override func awakeFromNib() {
        super.awakeFromNib()
        storedLocationPath = nil
    }

    override func mouseDown(with event: NSEvent) {
        let scaledImage = image
        let scaledSize = scaledImage?.size ?? .zero
        let point = NSPoint(
            x: (bounds.size.width - scaledSize.width) / 2,
            y: (bounds.size.height - scaledSize.height) / 2
        )

        let dragImage = NSImage(size: scaledSize, flipped: false) { _ in
            scaledImage?.draw(at: .zero, from: .zero, operation: .sourceOver, fraction: 0.5)
            return true
        }

        let item = NSPasteboardItem()
        if let tiff = image?.tiffRepresentation {
            item.setData(tiff, forType: .tiff)
        }
        if let location = imageLocationPath() {
            let fileURL = URL(fileURLWithPath: location)
            item.setString(fileURL.absoluteString, forType: .fileURL)
        }

        let dragItem = NSDraggingItem(pasteboardWriter: item)
        dragItem.setDraggingFrame(
            NSRect(x: point.x, y: point.y, width: scaledSize.width, height: scaledSize.height),
            contents: dragImage
        )
        beginDraggingSession(with: [dragItem], event: event, source: self)
    }

    override var needsPanelToBecomeKey: Bool {
        true
    }

    override var acceptsFirstResponder: Bool {
        true
    }

    func draggingSession(_ session: NSDraggingSession, sourceOperationMaskFor context: NSDraggingContext) -> NSDragOperation {
        if context == .withinApplication {
            return []
        }
        return [.generic, .copy]
    }

    @objc(setImageLocationPath:)
    func setImageLocationPath(_ path: String?) {
        guard let path, path.isEmpty == false else {
            return
        }
        storedLocationPath = String(path)
    }

    @objc func imageLocationPath() -> String? {
        storedLocationPath
    }
}
