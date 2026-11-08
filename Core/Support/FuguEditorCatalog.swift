import AppKit
import Foundation

/// One editor the File Editing popup can offer.
@objc(FuguEditorRecord)
final class FuguEditorRecord: NSObject {
    @objc let name: String
    @objc let bundleIdentifier: String
    @objc let path: String
    @objc let launchStyle: Int
    @objc let supportsODB: Bool

    init(name: String, bundleIdentifier: String, path: String, launchStyle: Int, supportsODB: Bool) {
        self.name = name
        self.bundleIdentifier = bundleIdentifier
        self.path = path
        self.launchStyle = launchStyle
        self.supportsODB = supportsODB
        super.init()
    }
}

private struct EditorSeed {
    let name: String
    let bundleIdentifier: String
    let path: String
    let launchStyle: Int
    let supportsODB: Bool
}

/// Known editors, filtered to the ones installed on this Mac, cached in the user defaults.
@objc(FuguEditorCatalog)
final class FuguEditorCatalog: NSObject {
    private static let cacheKey = "FuguInstalledEditors"
    private static let cacheDateKey = "FuguInstalledEditorsCachedAt"
    private static let preferredIDKey = "FuguPreferredEditorBundleID"
    private static let preferredNameKey = "ODBTextEditor"

    private static let seeds: [EditorSeed] = [
        EditorSeed(name: "CotEditor", bundleIdentifier: "com.coteditor.CotEditor", path: "", launchStyle: 0, supportsODB: true),
        EditorSeed(name: "BBEdit", bundleIdentifier: "com.barebones.bbedit", path: "", launchStyle: 0, supportsODB: true),
        EditorSeed(name: "TextMate", bundleIdentifier: "com.macromates.textmate", path: "", launchStyle: 0, supportsODB: true),
        EditorSeed(name: "Nova", bundleIdentifier: "com.panic.Nova", path: "", launchStyle: 0, supportsODB: false),
        EditorSeed(name: "Sublime Text", bundleIdentifier: "com.sublimetext.4", path: "", launchStyle: 0, supportsODB: false),
        EditorSeed(name: "Sublime Text 3", bundleIdentifier: "com.sublimetext.3", path: "", launchStyle: 0, supportsODB: false),
        EditorSeed(name: "Visual Studio Code", bundleIdentifier: "com.microsoft.VSCode", path: "", launchStyle: 0, supportsODB: false),
        EditorSeed(name: "Cursor", bundleIdentifier: "com.todesktop.230313mzl4w4u92", path: "", launchStyle: 0, supportsODB: false),
        EditorSeed(name: "Zed", bundleIdentifier: "dev.zed.Zed", path: "", launchStyle: 0, supportsODB: false),
        EditorSeed(name: "MacVim", bundleIdentifier: "org.vim.MacVim", path: "", launchStyle: 0, supportsODB: false),
        EditorSeed(name: "TextEdit", bundleIdentifier: "com.apple.TextEdit", path: "", launchStyle: 0, supportsODB: false),
        EditorSeed(name: "SubEthaEdit", bundleIdentifier: "de.codingmonkeys.SubEthaEdit", path: "", launchStyle: 0, supportsODB: true),
        EditorSeed(name: "Smultron", bundleIdentifier: "org.smultron.Smultron", path: "", launchStyle: 0, supportsODB: true),
        EditorSeed(name: "TextWrangler", bundleIdentifier: "com.barebones.textwrangler", path: "", launchStyle: 0, supportsODB: true),
        EditorSeed(name: "Jedit X", bundleIdentifier: "jp.co.artman21.JeditX", path: "", launchStyle: 0, supportsODB: true),
        EditorSeed(name: "PageSpinner", bundleIdentifier: "com.optima.PageSpinner", path: "", launchStyle: 0, supportsODB: true),
        EditorSeed(name: "CSSEdit", bundleIdentifier: "com.macrabbit.cssedit", path: "", launchStyle: 0, supportsODB: true),
        EditorSeed(name: "BBEdit Lite", bundleIdentifier: "com.barebones.bbeditlite", path: "", launchStyle: 0, supportsODB: true),
        EditorSeed(name: "vi", bundleIdentifier: "/usr/bin/vi", path: "/usr/bin/vi", launchStyle: 1, supportsODB: false),
        EditorSeed(name: "emacs", bundleIdentifier: "/usr/bin/emacs", path: "/usr/bin/emacs", launchStyle: 1, supportsODB: false),
    ]

    /// Installed editors in catalog order. A failed scan returns the last cached list.
    @objc static func installedEditors() -> [FuguEditorRecord] {
        let found = seeds.compactMap(resolve)
        if found.isEmpty {
            return cachedEditors()
        }
        let defaults = UserDefaults.standard
        defaults.set(found.map(dictionary(for:)), forKey: cacheKey)
        defaults.set(Date(), forKey: cacheDateKey)
        return found
    }

    /// The saved editor when it is still installed, otherwise the first installed editor.
    @objc static func preferredEditor() -> FuguEditorRecord? {
        let installed = installedEditors()
        let defaults = UserDefaults.standard
        if let identifier = defaults.string(forKey: preferredIDKey),
           let match = installed.first(where: { $0.bundleIdentifier == identifier }) {
            return match
        }
        if let name = defaults.string(forKey: preferredNameKey),
           let match = installed.first(where: { $0.name == name }) {
            return match
        }
        return installed.first
    }

    @objc(editorForBundleIdentifier:)
    static func editor(forBundleIdentifier identifier: String) -> FuguEditorRecord? {
        installedEditors().first { $0.bundleIdentifier == identifier }
    }

    @objc(storePreferredEditor:)
    static func storePreferredEditor(_ editor: FuguEditorRecord) {
        let defaults = UserDefaults.standard
        defaults.set(editor.name, forKey: preferredNameKey)
        defaults.set(editor.bundleIdentifier, forKey: preferredIDKey)
    }

    private static func resolve(_ seed: EditorSeed) -> FuguEditorRecord? {
        if seed.launchStyle == 1 {
            guard FileManager.default.isExecutableFile(atPath: seed.path) else {
                return nil
            }
            return FuguEditorRecord(
                name: seed.name,
                bundleIdentifier: seed.bundleIdentifier,
                path: seed.path,
                launchStyle: seed.launchStyle,
                supportsODB: seed.supportsODB
            )
        }
        guard let url = NSWorkspace.shared.urlForApplication(withBundleIdentifier: seed.bundleIdentifier) else {
            return nil
        }
        return FuguEditorRecord(
            name: seed.name,
            bundleIdentifier: seed.bundleIdentifier,
            path: url.path,
            launchStyle: 0,
            supportsODB: seed.supportsODB
        )
    }

    private static func dictionary(for editor: FuguEditorRecord) -> [String: Any] {
        [
            "name": editor.name,
            "bundleIdentifier": editor.bundleIdentifier,
            "path": editor.path,
            "launchStyle": editor.launchStyle,
            "supportsODB": editor.supportsODB,
        ]
    }

    private static func cachedEditors() -> [FuguEditorRecord] {
        guard let rows = UserDefaults.standard.array(forKey: cacheKey) as? [[String: Any]] else {
            return []
        }
        return rows.compactMap { row in
            guard let name = row["name"] as? String,
                  let bundleIdentifier = row["bundleIdentifier"] as? String,
                  let path = row["path"] as? String else {
                return nil
            }
            let launchStyle = row["launchStyle"] as? Int ?? 0
            let supportsODB = row["supportsODB"] as? Bool ?? false
            return FuguEditorRecord(
                name: name,
                bundleIdentifier: bundleIdentifier,
                path: path,
                launchStyle: launchStyle,
                supportsODB: supportsODB
            )
        }
    }
}
