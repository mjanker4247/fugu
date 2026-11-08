import Foundation

/// Toolbar item identifiers stored in `MainMenu.xib`. The strings match the old macros.
@objc(FuguToolbarIdentifier)
final class FuguToolbarIdentifier: NSObject {
    @objc static let localHome = "lhome"
    @objc static let newDirectory = "newdir"
    @objc static let delete = "delete"
    @objc static let connect = "connect"
    @objc static let info = "info"
    @objc static let remoteHome = "rhome"
    @objc static let refresh = "reload"
    @objc static let download = "download"
    @objc static let upload = "upload"
    @objc static let goTo = "gotodir"
    @objc static let localHistory = "lhistory"
    @objc static let remoteHistory = "rhistory"
    @objc static let preview = "preview"
    @objc static let edit = "edit"
}

/// Preference toolbar identifiers. The strings match the old macros in `SFTPPrefs.m`.
@objc(FuguPreferenceToolbarIdentifier)
final class FuguPreferenceToolbarIdentifier: NSObject {
    @objc static let general = "generalprefs"
    @objc static let favorites = "favoritesprefs"
    @objc static let knownHosts = "knownhostprefs"
    @objc static let files = "fileeditingprefs"
    @objc static let transfers = "transfersprefs"
}

/// Column widths formerly `#define`d in `SFTPTableView.h`. `Float` matches `WidthForColumnWithIdentifier`.
@objc(FuguColumnWidth)
final class FuguColumnWidth: NSObject {
    @objc static let date: Float = 100
    @objc static let group: Float = 70
    @objc static let mode: Float = 80
    @objc static let owner: Float = 70
    @objc static let size: Float = 70
}
