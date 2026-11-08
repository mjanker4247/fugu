import Darwin
import Foundation

/// Watches one remote-edit temp directory and asks the controller to upload after the file settles.
@objc(FuguEditorWatch)
final class FuguEditorWatch: NSObject {
    private static let settleDelay: TimeInterval = 0.5
    nonisolated(unsafe) private static var watches: [String: FuguEditorWatch] = [:]

    private let localPath: String
    private let remotePath: String
    private weak var target: NSObject?
    private let selector = NSSelectorFromString("uploadSettledEditAtLocalPath:remotePath:")
    private var directoryFD: Int32 = -1
    private var source: DispatchSourceFileSystemObject?
    private var work: DispatchWorkItem?
    private var pendingSize: Int64?
    private var allowedZero = false
    private var missingChecks = 0
    private var stopped = false
    private var lastUploadedMtime: TimeInterval
    private var lastUploadedSize: Int64

    private init(localPath: String, remotePath: String, target: NSObject, baselineMtime: TimeInterval, baselineSize: Int64) {
        self.localPath = localPath
        self.remotePath = remotePath
        self.target = target
        lastUploadedMtime = baselineMtime
        lastUploadedSize = baselineSize
        super.init()
    }

    /// Baseline is the file at this call. Call it after the editor has been asked to open the file.
    @objc(startWithLocalPath:remotePath:target:)
    static func start(withLocalPath localPath: String, remotePath: String, target: NSObject) {
        stop(forLocalPath: localPath)
        guard let baseline = stamp(at: localPath) else {
            NSLog("FuguEditorWatch: no file at %@", localPath)
            return
        }
        let watch = FuguEditorWatch(
            localPath: localPath,
            remotePath: remotePath,
            target: target,
            baselineMtime: baseline.mtime,
            baselineSize: baseline.size
        )
        guard watch.begin() else {
            return
        }
        watches[localPath] = watch
    }

    @objc(stopForLocalPath:)
    static func stop(forLocalPath localPath: String) {
        watches.removeValue(forKey: localPath)?.cancel()
    }

    @objc static func stopAll() {
        let open = Array(watches.values)
        watches.removeAll()
        open.forEach { $0.cancel() }
    }

    private func begin() -> Bool {
        let directory = (localPath as NSString).deletingLastPathComponent
        directoryFD = open(directory, O_EVTONLY)
        if directoryFD < 0 {
            NSLog("FuguEditorWatch: open %@: %s", directory, strerror(errno))
            return false
        }
        let source = DispatchSource.makeFileSystemObjectSource(
            fileDescriptor: directoryFD,
            eventMask: [.write, .rename, .delete, .extend],
            queue: .main
        )
        source.setEventHandler { [weak self] in
            self?.noteChange()
        }
        source.setCancelHandler { [directoryFD] in
            if directoryFD >= 0 {
                close(directoryFD)
            }
        }
        self.source = source
        source.resume()
        return true
    }

    private func cancel() {
        stopped = true
        target = nil
        work?.cancel()
        work = nil
        source?.cancel()
        source = nil
        directoryFD = -1
    }

    private func noteChange() {
        guard !stopped else {
            return
        }
        missingChecks = 0
        pendingSize = FuguEditorWatch.stamp(at: localPath)?.size
        scheduleSettle()
    }

    private func scheduleSettle() {
        work?.cancel()
        let item = DispatchWorkItem { [weak self] in
            self?.settle()
        }
        work = item
        DispatchQueue.main.asyncAfter(deadline: .now() + FuguEditorWatch.settleDelay, execute: item)
    }

    private func settle() {
        guard !stopped else {
            return
        }
        guard let stamp = FuguEditorWatch.stamp(at: localPath) else {
            missingChecks += 1
            if missingChecks < 3 {
                scheduleSettle()
            }
            return
        }
        missingChecks = 0
        guard let pendingSize, pendingSize == stamp.size else {
            self.pendingSize = stamp.size
            scheduleSettle()
            return
        }
        if stamp.size == 0 && lastUploadedSize > 0 && !allowedZero {
            allowedZero = true
            scheduleSettle()
            return
        }
        allowedZero = false
        guard stamp.mtime > lastUploadedMtime else {
            return
        }
        lastUploadedMtime = stamp.mtime
        lastUploadedSize = stamp.size
        guard let target, target.responds(to: selector) else {
            return
        }
        _ = target.perform(selector, with: localPath, with: remotePath)
    }

    private static func stamp(at path: String) -> (mtime: TimeInterval, size: Int64)? {
        var info = stat()
        if stat(path, &info) != 0 {
            return nil
        }
        let mtime = TimeInterval(info.st_mtimespec.tv_sec) + TimeInterval(info.st_mtimespec.tv_nsec) / 1_000_000_000
        return (mtime, Int64(info.st_size))
    }
}
