import Darwin
import Foundation

/// The current `forkpty` path. `Process` is not used until a Mac session shows the same prompts.
@objc(FuguSSHProcess)
final class FuguSSHProcess: NSObject {
    /// Same return as `forkpty`: 0 in the child, the child pid in the parent, -1 on failure.
    @objc(forkWithMaster:ttyName:windowRows:windowColumns:)
    static func fork(withMaster master: UnsafeMutablePointer<Int32>, ttyName: UnsafeMutablePointer<CChar>, windowRows: Int32, windowColumns: Int32) -> pid_t {
        var size = winsize()
        size.ws_row = UInt16(windowRows)
        size.ws_col = UInt16(windowColumns)
        size.ws_xpixel = 0
        size.ws_ypixel = 0
        return forkpty(master, ttyName, nil, &size)
    }

    /// `forkpty` with a null window size, which is what `scp` and the tunnel pass today.
    @objc(forkWithMaster:ttyName:)
    static func fork(withMaster master: UnsafeMutablePointer<Int32>, ttyName: UnsafeMutablePointer<CChar>) -> pid_t {
        forkpty(master, ttyName, nil, nil)
    }

    /// Reads through the next newline or carriage return. The sftp master fd is non-blocking, so "try again" is not the end of the session. Progress meters end in `\r` and then run out of bytes.
    @objc(readLine:size:fromStream:)
    static func readLine(_ buffer: UnsafeMutablePointer<CChar>, size: Int32, fromStream stream: UnsafeMutablePointer<FILE>) -> Bool {
        if size < 2 {
            return false
        }
        var count = 0
        let limit = Int(size) - 1
        while count < limit {
            let next = fgetc(stream)
            if next == EOF {
                let again = ferror(stream) != 0 && (errno == EAGAIN || errno == EWOULDBLOCK)
                if again {
                    clearerr(stream)
                    if count == 0 {
                        buffer[0] = 0
                        return true
                    }
                    break
                }
                if count == 0 {
                    return false
                }
                break
            }
            buffer[count] = CChar(truncatingIfNeeded: next)
            count += 1
            if next == 10 || next == 13 {
                break
            }
        }
        buffer[count] = 0
        return true
    }

    /// Same as `wait`. Returns the child pid, or -1. `status` is the raw status word.
    @objc(waitWithStatus:)
    static func reap(status: UnsafeMutablePointer<Int32>) -> pid_t {
        waitpid(-1, status, 0)
    }
}
