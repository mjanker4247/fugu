import AppKit
import Darwin
import UniformTypeIdentifiers

/// Icon lookup and the five-directory cache formerly on `NSImage(IconForType)`.
@objc(FuguIcons)
final class FuguIcons: NSObject {
    nonisolated(unsafe) private static var imagesByExtension: [String: NSImage] = [:]
    nonisolated(unsafe) private static var cachesByDirectory: [String: NSMutableDictionary] = [:]

    @objc(iconForType:)
    static func icon(forType extensionName: String?) -> NSImage? {
        guard let extensionName else {
            return nil
        }
        if let cached = imagesByExtension[extensionName] {
            return cached
        }
        let type = extensionName.isEmpty ? nil : UTType(filenameExtension: extensionName)
        let icon = NSWorkspace.shared.icon(for: type ?? .item)
        imagesByExtension[extensionName] = icon
        return icon
    }

    /// Falls back to `iconForType:` with the whole path, matching the old category.
    @objc(iconForFile:)
    static func icon(forFile file: String?) -> NSImage? {
        guard let file, !file.isEmpty else {
            return nil
        }
        let parent = (file as NSString).deletingLastPathComponent
        guard let icons = cachesByDirectory[parent] else {
            return icon(forType: file)
        }
        if let icon = icons[file] as? NSImage {
            return icon
        }
        return icon(forType: file)
    }

    @objc(cacheIconsForPath:contents:)
    static func cacheIcons(forPath path: String?, contents items: [String]?) {
        guard let path, !path.isEmpty, let items, !items.isEmpty else {
            return
        }

        if let existing = cachesByDirectory[path] {
            var info = stat()
            if stat(path, &info) < 0 {
                return
            }
            let stamp = existing["CacheTimestamp"] as? Date
            let cachedAt = stamp?.timeIntervalSince1970 ?? 0
            let now = Date().timeIntervalSince1970
            let modified = TimeInterval(info.st_mtimespec.tv_sec)
            if (now - cachedAt) < 10800 && cachedAt > modified {
                return
            }
            cachesByDirectory.removeValue(forKey: path)
        }

        let icons = NSMutableDictionary()
        for name in items {
            let file = (path as NSString).appendingPathComponent(name)
            guard let icon = NSWorkspace.shared.icon(forFile: file).copy() as? NSImage else {
                continue
            }
            icon.size = NSSize(width: 16, height: 16)
            icons[file] = icon
        }

        if cachesByDirectory.count >= 5, let newest = newestCacheKey() {
            cachesByDirectory.removeValue(forKey: newest)
        }
        icons["CacheTimestamp"] = Date()
        cachesByDirectory[path] = icons
    }

    /// The old `cacheDateCompare:` put the newest stamp last, and the caller dropped that entry.
    private static func newestCacheKey() -> String? {
        cachesByDirectory.max { lhs, rhs in
            let left = (lhs.value["CacheTimestamp"] as? Date) ?? .distantPast
            let right = (rhs.value["CacheTimestamp"] as? Date) ?? .distantPast
            return left < right
        }?.key
    }
}
