import AppKit

/// Same divider as the old `SFTPSplitView`. The XIB still names this class.
@objc(SFTPSplitView)
final class SFTPSplitView: NSSplitView {
    override var dividerThickness: CGFloat {
        20
    }
}
