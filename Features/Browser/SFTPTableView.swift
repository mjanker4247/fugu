/*
 * Copyright (c) 2005 Regents of The University of Michigan.
 * All Rights Reserved.  See COPYRIGHT.
 */

import AppKit

/// Browser table. Keeps the promised-file drag, the contextual menu, and Return-to-rename.
@objc(SFTPTableView)
final class SFTPTableView: NSTableView {
    private var rightClickedRowIndex = 0
    /// Drag phase and pasteboard snapshot. The legacy drag methods live in `SFTPTableViewDrag.m` because Swift marks them unavailable.
    @objc var dragPhase = 0
    private var springLoadedTimer: Timer?
    @objc var originalDragImage: NSImage?
    @objc var originalPboardTypes: NSArray?
    @objc var originalPboardPlists: NSMutableArray?
    @objc var dragPromisedFiles = false

    override func keyDown(with event: NSEvent) {
        if sendHandleEvent(event) == false {
            super.keyDown(with: event)
        }
    }

    override func namesOfPromisedFilesDropped(atDestination url: URL) -> [String]? {
        let plists = originalPboardPlists ?? NSMutableArray()
        let names = sendPromisedNames(plists)
        let first: Any = plists.count == 0 ? NSNull() : plists.object(at: 0)
        if sendHandleDroppedPromisedFiles(first, destination: url.path) == false {
            NSLog("failed to handle promised files")
        }
        originalPboardPlists = nil
        return names
    }

    override func draggingUpdated(_ sender: any NSDraggingInfo) -> NSDragOperation {
        let operation = super.draggingUpdated(sender)
        let event = NSApp.currentEvent
        guard let event, event.type == .keyDown else {
            return operation
        }

        if let characters = event.charactersIgnoringModifiers, characters.isEmpty == false {
            let key = (characters as NSString).character(at: 0)
            if key == 32 {
                let selector = NSSelectorFromString("performSpringLoadedActionInTable:")
                if delegate?.responds(to: selector) == true {
                    springLoadedTimer?.invalidate()
                    springLoadedTimer = nil
                    (delegate as? NSObject)?.perform(selector, with: self, afterDelay: 0)
                }
            }
        }

        let point = NSPoint(x: event.locationInWindow.x + 1, y: event.locationInWindow.y + 1)
        if let fake = NSEvent.mouseEvent(
            with: .leftMouseDragged,
            location: point,
            modifierFlags: event.modifierFlags,
            timestamp: event.timestamp + 0.1,
            windowNumber: event.windowNumber,
            context: nil,
            eventNumber: 1,
            clickCount: 0,
            pressure: 0
        ) {
            NSApp.postEvent(fake, atStart: true)
        }
        return operation
    }

    override func draggingExited(_ sender: (any NSDraggingInfo)?) {
        if springLoadedTimer != nil {
            springLoadedTimer?.invalidate()
            springLoadedTimer = nil
        }

        let selector = NSSelectorFromString("springLoadedActionCancelledInTable:")
        if delegate?.responds(to: selector) == true {
            (delegate as? NSObject)?.perform(selector, with: self, afterDelay: 0)
        }
        super.draggingExited(sender)
    }

    override var needsPanelToBecomeKey: Bool {
        true
    }

    override func menu(for event: NSEvent) -> NSMenu? {
        let point = convert(event.locationInWindow, from: nil)
        let column = self.column(at: point)
        let row = self.row(at: point)
        rightClickedRowIndex = 0

        let selector = NSSelectorFromString("menuForTable:column:row:")
        if column == 0, row >= 0, delegate?.responds(to: selector) == true {
            rightClickedRowIndex = row
            selectRowIndexes(IndexSet(integer: row), byExtendingSelection: false)
            return sendMenu(column: column, row: row)
        }
        return nil
    }

    override func textDidEndEditing(_ notification: Notification) {
        let movement = (notification.userInfo?["NSTextMovement"] as? NSNumber)?.intValue ?? 0
        if movement == NSTextMovement.return.rawValue {
            let column = editedColumn
            let selector = NSSelectorFromString("handleChangedText:forTable:column:")
            guard delegate?.responds(to: selector) == true else {
                NSSound.beep()
                super.textDidEndEditing(notification)
                return
            }
            let text = (notification.object as? NSText)?.string ?? ""
            sendChangedText(text, column: column)
            window?.endEditing(for: self)
            window?.makeFirstResponder(self)
            reloadData()
        } else {
            super.textDidEndEditing(notification)
        }
    }

    @objc func rightClickedRow() -> Int {
        rightClickedRowIndex
    }

    @objc func originOfSelectedCell() -> NSPoint {
        let row = selectedRow
        if row < 0 {
            return .zero
        }
        let cellFrame = frameOfCell(atColumn: 0, row: row)
        var origin = NSPoint(x: cellFrame.origin.x, y: cellFrame.origin.y)
        if let content = window?.contentView {
            origin = content.convert(origin, from: self)
        }
        if let window {
            origin = window.convertPoint(toScreen: origin)
        }
        return origin
    }

    @objc(addTableColumnWithIdentifier:columnTitle:width:)
    func addTableColumn(withIdentifier identifier: String, columnTitle title: String, width: Float) {
        if title.isEmpty {
            return
        }
        let column = NSTableColumn(identifier: NSUserInterfaceItemIdentifier(identifier))
        column.headerCell.stringValue = title
        column.minWidth = CGFloat(width / 2)
        column.maxWidth = CGFloat(width * 5)
        column.width = CGFloat(width)
        if identifier == "sizecolumn" {
            column.headerCell.alignment = .right
            if let cell = column.dataCell as? NSCell {
                cell.alignment = .right
            }
        }
        addTableColumn(column)
    }

    @objc(columnTitleFromIdentifier:)
    class func columnTitle(fromIdentifier identifier: String) -> String {
        if identifier == "datecolumn" {
            return NSLocalizedString("Date", comment: "Date")
        } else if identifier == "groupcolumn" {
            return NSLocalizedString("Group", comment: "Group")
        } else if identifier == "ownercolumn" {
            return NSLocalizedString("Owner", comment: "Owner")
        } else if identifier == "permcolumn" {
            return NSLocalizedString("Permissions", comment: "Permissions")
        } else if identifier == "sizecolumn" {
            return NSLocalizedString("Size", comment: "Size")
        }
        return ""
    }

    private func sendHandleEvent(_ event: NSEvent) -> Bool {
        guard let target = delegate as? NSObject else {
            return false
        }
        let selector = NSSelectorFromString("handleEvent:fromTable:")
        guard target.responds(to: selector) else {
            return false
        }
        typealias Imp = @convention(c) (AnyObject, Selector, NSEvent, SFTPTableView) -> ObjCBool
        let function = unsafeBitCast(target.method(for: selector), to: Imp.self)
        return function(target, selector, event, self).boolValue
    }

    private func sendPromisedNames(_ plists: NSArray) -> [String]? {
        guard let target = dataSource as? NSObject else {
            return nil
        }
        let selector = NSSelectorFromString("promisedNamesFromPlists:")
        guard target.responds(to: selector) else {
            return nil
        }
        typealias Imp = @convention(c) (AnyObject, Selector, NSArray) -> Unmanaged<NSArray>?
        let function = unsafeBitCast(target.method(for: selector), to: Imp.self)
        return function(target, selector, plists)?.takeUnretainedValue() as? [String]
    }

    private func sendHandleDroppedPromisedFiles(_ plist: Any, destination: String) -> Bool {
        guard let target = dataSource as? NSObject else {
            return false
        }
        let selector = NSSelectorFromString("handleDroppedPromisedFiles:destination:")
        guard target.responds(to: selector) else {
            return false
        }
        typealias Imp = @convention(c) (AnyObject, Selector, AnyObject, NSString) -> ObjCBool
        let function = unsafeBitCast(target.method(for: selector), to: Imp.self)
        let object = (plist as AnyObject)
        return function(target, selector, object, destination as NSString).boolValue
    }

    private func sendMenu(column: Int, row: Int) -> NSMenu? {
        guard let target = delegate as? NSObject else {
            return nil
        }
        let selector = NSSelectorFromString("menuForTable:column:row:")
        typealias Imp = @convention(c) (AnyObject, Selector, SFTPTableView, Int, Int) -> Unmanaged<NSMenu>?
        let function = unsafeBitCast(target.method(for: selector), to: Imp.self)
        return function(target, selector, self, column, row)?.takeUnretainedValue()
    }

    private func sendChangedText(_ text: String, column: Int) {
        guard let target = delegate as? NSObject else {
            return
        }
        let selector = NSSelectorFromString("handleChangedText:forTable:column:")
        typealias Imp = @convention(c) (AnyObject, Selector, NSString, SFTPTableView, Int) -> ObjCBool
        let function = unsafeBitCast(target.method(for: selector), to: Imp.self)
        _ = function(target, selector, text as NSString, self, column)
    }
}
