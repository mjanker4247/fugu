import Foundation

/// Lossless view of one `remoteObjectFromSFTPLine` dictionary.
/// The parser still returns `NSMutableDictionary`. This type does not replace those readers.
struct RemoteEntry {
    var name: String
    var nameRawBytes: Data
    var perm: String
    var type: String
    var owner: String?
    var group: String?
    var size: String
    var date: String

    init?(dictionary: NSDictionary) {
        guard let name = dictionary["name"] as? String,
              let nameRawBytes = dictionary["NameAsRawBytes"] as? Data,
              let perm = dictionary["perm"] as? String,
              let type = dictionary["type"] as? String,
              let size = dictionary["size"] as? String,
              let date = dictionary["date"] as? String else {
            return nil
        }
        self.name = name
        self.nameRawBytes = nameRawBytes
        self.perm = perm
        self.type = type
        self.owner = dictionary["owner"] as? String
        self.group = dictionary["group"] as? String
        self.size = size
        self.date = date
    }

    /// Writes the same keys the parser writes. Absent owner or group stays absent. `NameAsRawBytes` keeps that spelling.
    var dictionary: NSMutableDictionary {
        let result = NSMutableDictionary()
        result["name"] = name
        result["NameAsRawBytes"] = nameRawBytes
        result["perm"] = perm
        result["type"] = type
        result["size"] = size
        result["date"] = date
        if let owner {
            result["owner"] = owner
        }
        if let group {
            result["group"] = group
        }
        return result
    }
}

enum RemoteEntryRoundTrip {
    /// OpenSSH long form, old OpenSSH octal mode, and VShell. Owner may be the string `N/A` or absent.
    static func passes() -> Bool {
        let samples: [NSMutableDictionary] = [
            [
                "name": "notes.txt",
                "NameAsRawBytes": Data("notes.txt".utf8),
                "perm": "-rw-r--r--",
                "type": "file",
                "owner": "marco",
                "group": "staff",
                "size": "12",
                "date": "Jan 5 14:23"
            ],
            [
                "name": "old",
                "NameAsRawBytes": Data("old".utf8),
                "perm": "-rw-r--r--",
                "type": "file",
                "owner": "root",
                "group": "wheel",
                "size": "4",
                "date": "Jan 5 2022"
            ],
            [
                "name": "folder",
                "NameAsRawBytes": Data("folder".utf8),
                "perm": "d---------",
                "type": "directory",
                "owner": "N/A",
                "group": "N/A",
                "size": "0",
                "date": "Nov 6 09:01"
            ],
            [
                "name": "bare",
                "NameAsRawBytes": Data([0xC3, 0xA9]),
                "perm": "----------",
                "type": "file",
                "size": "1",
                "date": "Nov 6 09:01"
            ]
        ]
        for sample in samples {
            guard let entry = RemoteEntry(dictionary: sample) else {
                return false
            }
            let rebuilt = entry.dictionary
            if !rebuilt.isEqual(sample) {
                return false
            }
            if sample["owner"] == nil, rebuilt["owner"] != nil {
                return false
            }
        }
        let missing = NSMutableDictionary()
        missing["name"] = "x"
        return RemoteEntry(dictionary: missing) == nil
    }
}
