import CoreFoundation
import Foundation

/// Same date strings `NSDate(ConvertToSeconds)` accepted: `Jan 5 14:23`, `Jan 5 14:23 2022`, and `Jan 5 2022`.
@objc(FuguDate)
final class FuguDate: NSObject {
    @objc(secondsFromFormattedDateString:)
    static func seconds(from formatted: String) -> off_t {
        let months = [
            "jan": 1, "feb": 2, "mar": 3, "apr": 4,
            "may": 5, "jun": 6, "jul": 7, "aug": 8,
            "sep": 9, "oct": 10, "nov": 11, "dec": 12
        ]
        let parts = formatted.components(separatedBy: " ")
        let month = months[parts[0].lowercased()] ?? 0
        let day = Int(parts[1]) ?? 0
        var year = 0
        var hour = 0
        var minute = 0

        if parts[2].contains(":") {
            let clock = parts[2].components(separatedBy: ":")
            hour = Int(clock[0]) ?? 0
            minute = Int(clock[1]) ?? 0
            if parts.count == 4 {
                year = Int(parts[3]) ?? 0
            } else {
                let now = Calendar.current.dateComponents([.month, .year], from: Date())
                let currentMonth = now.month ?? 0
                year = now.year ?? 0
                if month > 6 && currentMonth >= 1 && currentMonth < 6 {
                    year -= 1
                }
            }
        } else {
            year = Int(parts[2]) ?? 0
        }

        var components = DateComponents()
        components.year = year
        components.month = month
        components.day = day
        components.hour = hour
        components.minute = minute
        components.second = 0
        let date = Calendar.current.date(from: components) ?? Date(timeIntervalSince1970: 0)
        return off_t(date.timeIntervalSince1970)
    }
}

/// Same encoding search as `NSString(UnknownEncoding)`. A nil buffer returns nil.
@objc(FuguStringEncoding)
final class FuguStringEncoding: NSObject {
    @objc(stringWithBytes:length:)
    static func string(withBytes bytes: UnsafeMutablePointer<CChar>?, length: UInt) -> String? {
        guard let bytes else {
            return nil
        }
        let internalEncodings: [CFStringEncoding] = [
            CFStringBuiltInEncodings.UTF8.rawValue,
            CFStringBuiltInEncodings.isoLatin1.rawValue,
            CFStringBuiltInEncodings.windowsLatin1.rawValue,
            CFStringBuiltInEncodings.nextStepLatin.rawValue
        ]
        if let converted = convert(bytes, length: length, encodings: internalEncodings, external: false) {
            return converted
        }
        // Values from CFStringEncodingExt.h. Swift does not import those kCFStringEncoding names.
        let externalEncodings: [CFStringEncoding] = [
            0x0202, 0x0203, 0x0204, 0x0205, 0x0206, 0x0207, 0x0208,
            0x0209, 0x020A, 0x020B, 0x020D, 0x020E, 0x020F,
            0x0501, 0x0502, 0x0503, 0x0504, 0x0505, 0x0506,
            0x0A02, 0x0A03,
            CFStringBuiltInEncodings.nextStepLatin.rawValue
        ]
        return convert(bytes, length: length, encodings: externalEncodings, external: true)
    }

    private static func convert(
        _ bytes: UnsafeMutablePointer<CChar>,
        length: UInt,
        encodings: [CFStringEncoding],
        external: Bool
    ) -> String? {
        let raw = UnsafeRawPointer(bytes).assumingMemoryBound(to: UInt8.self)
        for encoding in encodings {
            if external && !CFStringIsEncodingAvailable(encoding) {
                continue
            }
            if let created = CFStringCreateWithBytes(
                kCFAllocatorDefault,
                raw,
                CFIndex(length),
                encoding,
                external
            ) {
                return created as String
            }
        }
        return nil
    }
}

/// Alias checks formerly on `NSString(FSRefAdditions)`. A failed resolve returns the original path.
@objc(FuguPath)
final class FuguPath: NSObject {
    @objc(stringByResolvingAliasInPath:)
    static func stringByResolvingAlias(inPath path: String) -> String {
        let url = URL(fileURLWithPath: path)
        let resolved = try? URL(
            resolvingAliasFileAt: url,
            options: .withoutUI
        )
        return resolved?.path ?? path
    }

    @objc(isAliasFile:)
    static func isAliasFile(_ path: String) -> Bool {
        let url = URL(fileURLWithPath: path)
        let values = try? url.resourceValues(forKeys: [.isAliasFileKey])
        return values?.isAliasFile ?? false
    }
}

/// Gestalt-packed `0xMMmmpp` value. No caller remains. The packing stays so a later step can read it.
@objc(FuguSystemVersion)
final class FuguSystemVersion: NSObject {
    @objc static func gestaltPacked() -> Int32 {
        let version = ProcessInfo.processInfo.operatingSystemVersion
        return Int32((version.majorVersion << 8) | (version.minorVersion << 4) | version.patchVersion)
    }
}
