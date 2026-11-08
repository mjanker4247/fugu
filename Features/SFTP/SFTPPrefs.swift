/*
 * Copyright (c) 2003 Regents of The University of Michigan.
 * All Rights Reserved.  See COPYRIGHT.
 */

import AppKit
import Darwin

/// Preferences panel. Toolbar panes, favorites, known hosts, and the editor popup.
@MainActor
@objc(SFTPPrefs)
final class SFTPPrefs: NSObject, NSToolbarDelegate, NSTableViewDelegate, NSTableViewDataSource {
    @objc static let changedNotification = "SFTPPrefsChangedNotification"

    @IBOutlet var prefDefaultHost: NSComboBox?
    @IBOutlet var prefDefaultUser: NSTextField?
    @IBOutlet var prefDefaultLDir: NSTextField?
    @IBOutlet var prefDefaultRDir: NSTextField?
    @IBOutlet var prefDefaultPort: NSTextField?
    @IBOutlet var prefFavTable: SFTPPrefTableView?
    @IBOutlet var prefPanel: NSPanel?
    @IBOutlet var prefViewBox: NSBox?
    @IBOutlet var prefGeneralView: NSView?
    @IBOutlet var prefFavoritesView: NSView?
    @IBOutlet var prefKnownHostsView: NSView?
    @IBOutlet var prefKnownHostsTable: SFTPPrefTableView?
    @IBOutlet var prefFilesView: NSView?
    @IBOutlet var prefTextEditorPopUp: NSPopUpButton?
    @IBOutlet var prefPostEditMatrix: NSSegmentedControl?
    @IBOutlet var prefSortingMatrix: NSSegmentedControl?
    @IBOutlet var prefSSHPath: NSComboBox?
    @IBOutlet var prefTransfersView: NSView?
    @IBOutlet var prefRetainFileTimeSwitch: NSButton?

    private var favs: NSMutableArray?
    nonisolated(unsafe) private static var knownHosts: NSMutableArray?

    @objc func showPreferencePanel() {
        prefPanel?.makeKeyAndOrderFront(nil)
    }

    private func toolbarSetup() {
        let toolbar = NSToolbar(identifier: "SFTPPrefToolbar")
        toolbar.allowsUserCustomization = false
        toolbar.autosavesConfiguration = false
        toolbar.displayMode = .iconAndLabel
        toolbar.delegate = self
        prefPanel?.toolbar = toolbar
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        let protoCell = NSButtonCell()
        protoCell.title = ""
        protoCell.setButtonType(.switch)
        protoCell.isEditable = true
        if let column = prefFavTable?.tableColumn(withIdentifier: NSUserInterfaceItemIdentifier("ssh1")) {
            column.dataCell = protoCell
        }
        if let column = prefFavTable?.tableColumn(withIdentifier: NSUserInterfaceItemIdentifier("compress")) {
            column.dataCell = protoCell
        }

        favs = NSMutableArray()
        prefFavTable?.delegate = self
        prefFavTable?.dataSource = self
        prefKnownHostsTable?.delegate = self
        prefKnownHostsTable?.dataSource = self
        prefDefaultHost?.completes = true
        toolbarSetup()
        readFavorites()
        readGeneralPrefs()
        prefFavTable?.reloadData()
        showGeneralPreferences(nil)
        prefPanel?.center()
        prefPanel?.makeKeyAndOrderFront(nil)

        prefPostEditMatrix?.setLabel("Reopen in Fugu", forSegment: 0)
        prefPostEditMatrix?.setLabel("Leave Hidden", forSegment: 1)
        prefSortingMatrix?.setLabel("Alphabetical", forSegment: 0)
        prefSortingMatrix?.setLabel("ASCII Order", forSegment: 1)
    }

    func toolbar(_ toolbar: NSToolbar, itemForItemIdentifier itemIdentifier: NSToolbarItem.Identifier, willBeInsertedIntoToolbar flag: Bool) -> NSToolbarItem? {
        let item = NSToolbarItem(itemIdentifier: itemIdentifier)
        let ident = itemIdentifier.rawValue
        if ident == FuguPreferenceToolbarIdentifier.general {
            apply(item, label: "General", tooltip: "Show General Preferences", image: "generalprefs.png", action: #selector(showGeneralPreferences(_:)))
        } else if ident == FuguPreferenceToolbarIdentifier.favorites {
            apply(item, label: "Favorites", tooltip: "Show Favorites", image: "favoritesprefs.png", action: #selector(showFavorites(_:)))
        } else if ident == FuguPreferenceToolbarIdentifier.transfers {
            apply(item, label: "Transfers", tooltip: "Show Transfer Preferences", image: "transfers.png", action: #selector(showTransfersPrefs(_:)))
        } else if ident == FuguPreferenceToolbarIdentifier.files {
            apply(item, label: "Files", tooltip: "Show Text File Editing Preferences", image: "files.png", action: #selector(showFilesPrefs(_:)))
        } else if ident == FuguPreferenceToolbarIdentifier.knownHosts {
            apply(item, label: "Known Hosts", tooltip: "Known Host Manager", image: "knownhosts.png", action: #selector(showKnownHosts(_:)))
        }
        return item
    }

    func validateToolbarItem(_ item: NSToolbarItem) -> Bool {
        true
    }

    func toolbarDefaultItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
        preferenceIdentifiers()
    }

    func toolbarAllowedItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
        preferenceIdentifiers()
    }

    private func readKnownHosts() {
        let knownHostsPath = (NSHomeDirectory() as NSString).appendingPathComponent(".ssh/known_hosts")
        guard let file = fopen(knownHostsPath, "r") else {
            let reason = String(cString: strerror(errno))
            showPrefsError("Couldn't open ~/.ssh/known_hosts.\nfopen \(knownHostsPath): \(reason)")
            return
        }
        defer { fclose(file) }

        SFTPPrefs.knownHosts?.removeAllObjects()
        var buffer = [CChar](repeating: 0, count: Int(LINE_MAX))
        while fgets(&buffer, CInt(LINE_MAX), file) != nil {
            guard let line = strdup(buffer) else {
                perror("strdup")
                exit(2)
            }
            var argv: UnsafeMutablePointer<UnsafeMutablePointer<CChar>?>?
            let count = withUnsafeMutablePointer(to: &argv) { pointer in
                acav_parse(nil, line, pointer)
            }
            if count != 3 {
                free(line)
                continue
            }
            if SFTPPrefs.knownHosts == nil {
                SFTPPrefs.knownHosts = NSMutableArray()
            }
            let host = String(cString: argv![0]!)
            let keyType = String(cString: argv![1]!)
            let key = String(cString: argv![2]!)
            free(line)
            SFTPPrefs.knownHosts?.add(NSMutableDictionary(dictionary: [
                "hostid": host,
                "keytype": keyType,
                "key": key,
            ]))
        }
        prefKnownHostsTable?.reloadData()
    }

    @objc func showGeneralPreferences(_ sender: Any?) {
        guard let general = prefGeneralView, prefViewBox?.contentView !== general else {
            return
        }
        resizeBox(to: general.frame)
        prefPanel?.title = NSLocalizedString("Fugu Preferences: General", comment: "Fugu Preferences: General")
        prefViewBox?.contentView = general
    }

    @objc func showFavorites(_ sender: Any?) {
        guard let favorites = prefFavoritesView, prefViewBox?.contentView !== favorites else {
            return
        }
        resizeBox(to: favorites.frame)
        prefViewBox?.contentView = favorites
        prefPanel?.title = NSLocalizedString("Fugu Preferences: Favorites Editor", comment: "Fugu Preferences: Favorites Editor")
        prefFavTable?.window?.makeFirstResponder(prefFavTable)
    }

    @objc func showKnownHosts(_ sender: Any?) {
        guard let hosts = prefKnownHostsView, prefViewBox?.contentView !== hosts else {
            return
        }
        resizeBox(to: hosts.frame)
        readKnownHosts()
        prefViewBox?.contentView = hosts
        prefPanel?.title = NSLocalizedString("Fugu Preferences: SSH Known Hosts Editor", comment: "Fugu Preferences: SSH Known Hosts Editor")
    }

    @objc func showFilesPrefs(_ sender: Any?) {
        guard let files = prefFilesView, prefViewBox?.contentView !== files else {
            return
        }

        let editors = FuguEditorCatalog.installedEditors()
        let defaults = UserDefaults.standard
        let savedID = defaults.string(forKey: "FuguPreferredEditorBundleID")
        let savedName = defaults.string(forKey: "ODBTextEditor")
        prefTextEditorPopUp?.removeAllItems()
        var match: NSMenuItem?
        for editor in editors {
            let item = NSMenuItem(title: editor.name, action: nil, keyEquivalent: "")
            item.representedObject = editor.bundleIdentifier
            if let icon = NSWorkspace.shared.icon(forFile: editor.path) as NSImage? {
                icon.size = NSSize(width: 16, height: 16)
                item.image = icon
            }
            prefTextEditorPopUp?.menu?.addItem(item)
            if match == nil, let savedID, editor.bundleIdentifier == savedID {
                match = item
            }
        }
        if match == nil, let savedName {
            match = prefTextEditorPopUp?.item(withTitle: savedName)
        }
        if let match {
            prefTextEditorPopUp?.select(match)
        } else if (prefTextEditorPopUp?.numberOfItems ?? 0) > 0 {
            prefTextEditorPopUp?.selectItem(at: 0)
            setODBTextEditor(prefTextEditorPopUp)
        }

        let behaviour = (defaults.object(forKey: "PostEditBehaviour") as? NSNumber)?.intValue ?? 0
        prefPostEditMatrix?.selectedSegment = behaviour
        prefSortingMatrix?.selectedSegment = defaults.bool(forKey: "ASCIIOrderSorting") ? 1 : 0

        if let sshPath = defaults.string(forKey: "ExecutableSearchPath") {
            if prefSSHPath?.indexOfItem(withObjectValue: sshPath) == NSNotFound {
                prefSSHPath?.addItem(withObjectValue: sshPath)
            }
            prefSSHPath?.stringValue = sshPath
            prefSSHPath?.selectItem(withObjectValue: sshPath)
        }

        resizeBox(to: files.frame)
        prefViewBox?.contentView = files
        prefPanel?.title = NSLocalizedString("Fugu Preferences: File Editing", comment: "Fugu Preferences: File Editing")
    }

    @objc func showTransfersPrefs(_ sender: Any?) {
        guard let transfers = prefTransfersView, prefViewBox?.contentView !== transfers else {
            return
        }
        resizeBox(to: transfers.frame)
        let retainTime = UserDefaults.standard.bool(forKey: "RetainFileTimestamp")
        prefRetainFileTimeSwitch?.state = retainTime ? .on : .off
        prefViewBox?.contentView = transfers
        prefPanel?.title = NSLocalizedString("Fugu Preferences: Transfers", comment: "Fugu Preferences: Transfers")
    }

    @IBAction func toggleRetainFileTime(_ sender: Any?) {
        let on = prefRetainFileTimeSwitch?.state == .on
        UserDefaults.standard.set(on, forKey: "RetainFileTimestamp")
    }

    @IBAction func setPostEditBehaviour(_ sender: Any?) {
        let row = prefPostEditMatrix?.selectedSegment ?? 0
        UserDefaults.standard.set(NSNumber(value: row), forKey: "PostEditBehaviour")
    }

    @IBAction func setSortingBehaviour(_ sender: Any?) {
        let row = prefSortingMatrix?.selectedSegment ?? 0
        UserDefaults.standard.set(row != 0, forKey: "ASCIIOrderSorting")
    }

    @IBAction func setSSHPath(_ sender: Any?) {
        let value = (sender as? NSControl)?.stringValue ?? ""
        UserDefaults.standard.set(value, forKey: "ExecutableSearchPath")
    }

    @IBAction func deleteKnownHost(_ sender: Any?) {
        let row = prefKnownHostsTable?.selectedRow ?? -1
        if row < 0 {
            NSLog("Attempted to delete invalid row.")
            return
        }
        SFTPPrefs.knownHosts?.removeObject(at: row)
        prefKnownHostsTable?.reloadData()
    }

    @IBAction func saveKnownHosts(_ sender: Any?) {
        var path = [CChar](repeating: 0, count: Int(MAXPATHLEN))
        var backup = [CChar](repeating: 0, count: Int(MAXPATHLEN))
        let home = NSHomeDirectory()
        let pathString = (home as NSString).appendingPathComponent(".ssh/known_hosts")
        if pathString.lengthOfBytes(using: .utf8) > Int(MAXPATHLEN) - 1 {
            showPrefsError("\(home)/.ssh/known_hosts: path too long")
            return
        }
        pathString.withCString { source in
            _ = strlcpy(&path, source, path.count)
        }

        var hasFile = true
        if access(path, R_OK | W_OK | F_OK) < 0 {
            if errno != ENOENT {
                let reason = String(cString: strerror(errno))
                showPrefsError("access \(String(cString: path)): \(reason)")
                return
            }
            hasFile = false
        }

        if hasFile {
            if strlcpy(&backup, path, backup.count) >= backup.count {
                showPrefsError("strlcpy failed: string exceeds bounds.")
                return
            }
            if strlcat(&backup, ".backup", backup.count) >= backup.count {
                showPrefsError("strlcat \(String(cString: backup)) failed: string exceeds bounds.")
                return
            }
            if rename(path, backup) != 0 {
                let reason = String(cString: strerror(errno))
                showPrefsError("rename \(String(cString: path)) to \(String(cString: backup)): \(reason)")
                return
            }
        }

        guard let file = fopen(path, "w+") else {
            let reason = String(cString: strerror(errno))
            showPrefsError("fopen \(String(cString: path)): \(reason)")
            rename(backup, path)
            return
        }
        let hosts = SFTPPrefs.knownHosts ?? []
        for case let dict as NSDictionary in hosts {
            let host = dict["hostid"] as? String ?? ""
            let keyType = dict["keytype"] as? String ?? ""
            let key = dict["key"] as? String ?? ""
            let line = "\(host) \(keyType) \(key)\n"
            line.withCString { fputs($0, file) }
        }
        fclose(file)
    }

    @objc func readFavorites() {
        favs?.removeAllObjects()
        let stored = UserDefaults.standard.array(forKey: "Favorites") ?? []
        let favorites = NSMutableArray(array: stored)
        for index in 0..<favorites.count {
            if let host = favorites[index] as? String {
                let dict = NSMutableDictionary.favoriteDictionary(fromHostname: host)
                favorites.replaceObject(at: index, with: dict)
            }
        }
        favs?.addObjects(from: favorites as! [Any])
        UserDefaults.standard.set(favs, forKey: "Favorites")
    }

    @objc func readGeneralPrefs() {
        let defaults = UserDefaults.standard
        let defaultHost = defaults.object(forKey: "defaulthost")
        if let host = defaultHost as? String {
            prefDefaultHost?.stringValue = host
        } else if let host = (defaultHost as? NSDictionary)?["host"] as? String {
            prefDefaultHost?.stringValue = host
        }
        if let user = defaults.string(forKey: "defaultuser") {
            prefDefaultUser?.stringValue = user
        }
        if let port = defaults.string(forKey: "defaultport") {
            prefDefaultPort?.stringValue = port
        }
        if let remote = defaults.string(forKey: "defaultrdir") {
            prefDefaultRDir?.stringValue = remote
        }
        if let local = defaults.string(forKey: "defaultdir") {
            prefDefaultLDir?.stringValue = local
        }
        let count = favs?.count ?? 0
        for index in 0..<count {
            let host = (favs?[index] as? NSDictionary)?["host"]
            prefDefaultHost?.addItem(withObjectValue: host as Any)
        }
    }

    @IBAction func setODBTextEditor(_ sender: Any?) {
        let item = prefTextEditorPopUp?.selectedItem
        let identifier = item?.representedObject as? String
        if let identifier, let editor = FuguEditorCatalog.editor(forBundleIdentifier: identifier) {
            FuguEditorCatalog.storePreferredEditor(editor)
            return
        }
        if let title = item?.title {
            UserDefaults.standard.set(title, forKey: "ODBTextEditor")
        }
    }

    @IBAction func addFavorite(_ sender: Any?) {
        let dict = NSMutableDictionary(dictionary: [
            "nick": "newhost",
            "host": "unreal.hostname.local",
            "user": "",
            "port": "",
            "dir": "",
        ])
        favs?.add(dict)
        prefFavTable?.reloadData()
        let row = (favs?.count ?? 1) - 1
        prefFavTable?.selectRowIndexes(IndexSet(integer: row), byExtendingSelection: false)
        prefFavTable?.editColumn(0, row: row, with: nil, select: true)
    }

    @IBAction func setGeneralDefaults(_ sender: Any?) {
        let defaults = UserDefaults.standard
        if let host = prefDefaultHost?.stringValue, host.isEmpty == false {
            defaults.set(host, forKey: "defaulthost")
        }
        if let user = prefDefaultUser?.stringValue, user.isEmpty == false {
            defaults.set(user, forKey: "defaultuser")
        }
        if let port = prefDefaultPort?.stringValue, port.isEmpty == false {
            defaults.set(port, forKey: "defaultport")
        }
        if let remote = prefDefaultRDir?.stringValue, remote.isEmpty == false {
            defaults.set(remote, forKey: "defaultrdir")
        }
        if let local = prefDefaultLDir?.stringValue, local.isEmpty == false {
            defaults.set(local, forKey: "defaultdir")
        }
        defaults.synchronize()
        readGeneralPrefs()
    }

    private func showPrefsError(_ message: String) {
        let alert = NSAlert()
        alert.messageText = NSLocalizedString("Error", comment: "Error")
        alert.informativeText = message
        alert.addButton(withTitle: NSLocalizedString("OK", comment: "OK"))
        guard let prefPanel else {
            return
        }
        alert.beginSheetModal(for: prefPanel, completionHandler: nil)
    }

    @IBAction func clearDefaults(_ sender: Any?) {
        let alert = NSAlert()
        alert.messageText = NSLocalizedString("Clear Defaults?", comment: "Clear Defaults?")
        alert.addButton(withTitle: NSLocalizedString("Clear", comment: "Clear"))
        alert.addButton(withTitle: NSLocalizedString("Cancel", comment: "Cancel"))
        guard let prefPanel else {
            return
        }
        alert.beginSheetModal(for: prefPanel) { response in
            if response != .alertFirstButtonReturn {
                return
            }
            let defaults = UserDefaults.standard
            defaults.set("", forKey: "defaulthost")
            defaults.set("", forKey: "defaultuser")
            defaults.set("", forKey: "defaultport")
            defaults.set("", forKey: "defaultdir")
            defaults.set("", forKey: "defaultrdir")
            self.readGeneralPrefs()
        }
    }

    @IBAction func deleteFavorite(_ sender: Any?) {
        guard let row = prefFavTable?.selectedRow, row >= 0 else {
            return
        }
        if (favs?.count ?? 0) > 0 {
            favs?.removeObject(at: row)
        }
        UserDefaults.standard.set(favs, forKey: "Favorites")
        NotificationCenter.default.post(name: Notification.Name(SFTPPrefs.changedNotification), object: nil)
        prefFavTable?.reloadData()
    }

    @IBAction func dismissPrefPanel(_ sender: Any?) {
        prefPanel?.close()
    }

    @IBAction func chooseDefaultLocalDirectory(_ sender: Any?) {
        let panel = NSOpenPanel()
        let directory = UserDefaults.standard.string(forKey: "NSDefaultOpenDirectory") ?? NSHomeDirectory()
        panel.canChooseFiles = false
        panel.canChooseDirectories = true
        panel.title = "Choose a Default Folder"
        panel.prompt = "Choose"
        panel.directoryURL = URL(fileURLWithPath: directory, isDirectory: true)
        guard let prefPanel else {
            return
        }
        panel.beginSheetModal(for: prefPanel) { response in
            if response != .OK {
                return
            }
            if let path = panel.urls.first?.path {
                self.prefDefaultLDir?.stringValue = path
            }
        }
    }

    func numberOfRows(in tableView: NSTableView) -> Int {
        if tableView === prefFavTable {
            return favs?.count ?? 0
        } else if tableView === prefKnownHostsTable {
            return SFTPPrefs.knownHosts?.count ?? 0
        }
        return 0
    }

    func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {
        let identifier = tableColumn?.identifier.rawValue ?? ""
        if tableView === prefFavTable {
            if let host = favs?[row] as? String, identifier == "host" {
                return host
            }
            return (favs?[row] as? NSDictionary)?[identifier]
        } else if tableView === prefKnownHostsTable {
            return (SFTPPrefs.knownHosts?[row] as? NSDictionary)?[identifier]
        }
        return nil
    }

    func tableView(_ tableView: NSTableView, setObjectValue object: Any?, for tableColumn: NSTableColumn?, row: Int) {
        guard tableView === prefFavTable, let favs else {
            return
        }
        if favs.count <= 0 || favs.count <= row {
            return
        }
        let identifier = tableColumn?.identifier.rawValue ?? ""
        if favs[row] is String, identifier == "fhost" {
            let host = favs[row] as! String
            let dict = NSMutableDictionary.favoriteDictionary(fromHostname: host)
            favs.replaceObject(at: row, with: dict)
            return
        }
        guard let dict = (favs[row] as? NSDictionary)?.mutableCopy() as? NSMutableDictionary else {
            return
        }
        if let object {
            dict[identifier] = object
        }
        favs.replaceObject(at: row, with: dict)
        UserDefaults.standard.set(favs, forKey: "Favorites")
        NotificationCenter.default.post(name: Notification.Name(SFTPPrefs.changedNotification), object: nil)
    }

    private func resizeBox(to newRect: NSRect) {
        guard let box = prefViewBox, let panel = prefPanel else {
            return
        }
        var boxRect = box.frame
        var windowRect = panel.frame
        windowRect.size.height -= boxRect.height - newRect.height
        windowRect.size.width -= boxRect.width - newRect.width
        windowRect.origin.y += boxRect.height - newRect.height
        boxRect.size.height = newRect.height
        boxRect.size.width = newRect.width
        box.contentView = nil
        box.frame = boxRect
        panel.setFrame(windowRect, display: true, animate: true)
    }

    private func preferenceIdentifiers() -> [NSToolbarItem.Identifier] {
        [
            NSToolbarItem.Identifier(FuguPreferenceToolbarIdentifier.general),
            NSToolbarItem.Identifier(FuguPreferenceToolbarIdentifier.favorites),
            NSToolbarItem.Identifier(FuguPreferenceToolbarIdentifier.transfers),
            NSToolbarItem.Identifier(FuguPreferenceToolbarIdentifier.files),
            NSToolbarItem.Identifier(FuguPreferenceToolbarIdentifier.knownHosts),
        ]
    }

    private func apply(_ item: NSToolbarItem, label: String, tooltip: String, image: String, action: Selector) {
        let title = NSLocalizedString(label, tableName: "SFTPPrefToolbar", comment: label)
        item.label = title
        item.paletteLabel = title
        item.toolTip = NSLocalizedString(tooltip, tableName: "SFTPPrefToolbar", comment: tooltip)
        item.image = NSImage(named: image)
        item.action = action
        item.target = self
    }
}
