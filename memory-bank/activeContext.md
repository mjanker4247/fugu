# Active Context

## Current Focus

Step 2 code is on `migrate/step-02-spm-and-native-replacements`. The Development build succeeded. The manual checks have not run.

## Status

`FuguTemporaryDirectory` creates `/private/tmp/Fugu` with `FileManager` and the unique child with `mkdtemp`. `SFTPController` calls it at both former `makeTemporaryDirectoryWithMode:` sites. `NSFileManager(mktemp)` is deleted.

`FuguKeychain` calls `getpwdfromkeychain` and `addpwdtokeychain`. `keychain.c` still owns `SecItem`. The retrieve and add methods in `SFTPController`, `SCPController`, and `SSHTunnel` call the Swift type. The bridging header includes `keychain.h`.

## Next action

Do not start Step 3. Still open:

- Commit is not done. The user has not asked for one. A clean checkout of `c3bdfcc` does not build, and this branch was created from that commit.
- SSH connect, list, upload, download.
- Preview or edit creates a directory under `/private/tmp/Fugu`.
- Password save and fill on the SFTP sheet.
- Quit removes `/private/tmp/Fugu` when that directory is writable.

## Latest Changes

- Branch: `migrate/step-02-spm-and-native-replacements`
- Build: `xcodebuild -project Fugu.xcodeproj -scheme Fugu -configuration Development build` → BUILD SUCCEEDED in 6.7 seconds
- `SwiftCompile`: `FuguKeychain.swift`, `FuguTemporaryDirectory.swift`, `FuguSwiftBridge.swift`
- Warnings: existing `iconForFileType:` deprecations only
