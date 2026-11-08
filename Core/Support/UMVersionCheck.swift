import AppKit
import Foundation

private struct FlexibleDouble: Decodable {
    let value: Double

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let number = try? container.decode(Double.self) {
            value = number
            return
        }
        if let number = try? container.decode(Int.self) {
            value = Double(number)
            return
        }
        if let text = try? container.decode(String.self), let number = Double(text) {
            value = number
            return
        }
        value = 0
    }
}

private struct FlexibleString: Decodable {
    let value: String

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let text = try? container.decode(String.self) {
            value = text
            return
        }
        if let number = try? container.decode(Double.self) {
            value = String(number)
            return
        }
        value = ""
    }
}

private struct VersionPlist: Decodable {
    let UMApplicationVersion: FlexibleDouble?
    let UMApplicationName: FlexibleString?
    let UMApplicationDisplayVersion: FlexibleString?
    let UMApplicationInformationURL: FlexibleString?
    let UMApplicationDirectDownloadURL: FlexibleString?
}

/// Same update sheet as the old `UMVersionCheck`. The URL stays the http plist.
@objc(UMVersionCheck)
final class UMVersionCheck: NSObject {
    @objc static let versionURL = "http://rsug.itd.umich.edu/software/fugu/version.plist"

    @objc func checkForUpdates() {
        guard let url = URL(string: UMVersionCheck.versionURL) else {
            NSLog("UMVersionCheck: invalid VERSION_URL")
            return
        }
        URLSession.shared.dataTask(with: url) { data, _, error in
            if let error {
                DispatchQueue.main.async {
                    let alert = NSAlert()
                    alert.messageText = NSLocalizedString(
                        "An error occurred checking for updates.",
                        comment: "An error occurred checking for updates."
                    )
                    alert.informativeText = NSLocalizedString(
                        "Please check to make sure that you are connected to the internet. If you are connected, and the problem persists, please contact the authors of Fugu.",
                        comment: "Please check to make sure that you are connected to the internet. If you are connected, and the problem persists, please contact the authors of Fugu."
                    )
                    alert.addButton(withTitle: NSLocalizedString("OK", comment: "OK"))
                    alert.runModal()
                }
                return
            }
            guard let data else {
                NSLog("UMVersionCheck: failed to parse version plist: no data")
                return
            }
            let versionDictionary: VersionPlist
            do {
                versionDictionary = try PropertyListDecoder().decode(VersionPlist.self, from: data)
            } catch {
                NSLog("UMVersionCheck: failed to parse version plist: %@", error.localizedDescription)
                return
            }
            DispatchQueue.main.async {
                UMVersionCheck.present(versionDictionary)
            }
        }.resume()
    }

    /// Kept so older callers still link. It does not fetch.
    @objc func retrieveVersionDictionary() -> NSDictionary? {
        nil
    }

    private static func present(_ versionDictionary: VersionPlist) {
        let info = Bundle.main.infoDictionary
        let current = (info?["UMVersionNumber"] as? NSNumber)?.doubleValue ?? 0
        let remote = versionDictionary.UMApplicationVersion?.value ?? 0
        let name = versionDictionary.UMApplicationName?.value ?? ""
        if remote <= current {
            let alert = NSAlert()
            alert.messageText = String(
                format: NSLocalizedString(
                    "You have the current version of %@.",
                    comment: "You have the current version of %@."
                ),
                name
            )
            alert.addButton(withTitle: NSLocalizedString("OK", comment: "OK"))
            alert.runModal()
            return
        }

        let alert = NSAlert()
        alert.messageText = String(
            format: NSLocalizedString(
                "A new version of %@ is now available.",
                comment: "A new version of %@ is now available."
            ),
            name
        )
        alert.informativeText = String(
            format: NSLocalizedString(
                "The latest version of %@ is %@. Click \"More Info\" to open a web page about the new release. Click \"Download\" to download the new version immediately.",
                comment: "The latest version of %@ is %@. Click \"More Info\" to open a web page about the new release. Click \"Download\" to download the new version immediately."
            ),
            name,
            versionDictionary.UMApplicationDisplayVersion?.value ?? ""
        )
        alert.addButton(withTitle: NSLocalizedString("More Info...", comment: "More Info..."))
        alert.addButton(withTitle: NSLocalizedString("Download", comment: "Download"))
        alert.addButton(withTitle: NSLocalizedString("Later", comment: "Later"))
        let response = alert.runModal()
        if response == .alertFirstButtonReturn, let text = versionDictionary.UMApplicationInformationURL?.value, let page = URL(string: text) {
            NSWorkspace.shared.open(page)
        } else if response == .alertSecondButtonReturn, let text = versionDictionary.UMApplicationDirectDownloadURL?.value, let page = URL(string: text) {
            NSWorkspace.shared.open(page)
        }
    }
}
