# TASK ARCHIVE: Step 1 project layout and bridging

## METADATA

- **Task ID**: step-01
- **Name**: `migrate/step-01-project-structure-and-bridging`
- **Parent**: Fugu Objective-C to Swift migration (Level 4). Steps 2–6 are not this archive.
- **Complexity**: Level 4, this slice is configuration only
- **Dates**: Mac build 5 Nov 2026. Reflection and archive 6 Nov 2026.
- **Branch**: `migrate/step-01-project-structure-and-bridging`
- **Pushed commit**: `c3bdfcc` — file moves plus `App/FuguSwiftBridge.swift` and `App/Fugu-Bridging-Header.h`
- **Status**: Archived with two open gaps. The six-step migration is not complete.

## SUMMARY

Step 1 moved Fugu sources into feature folders, added an empty bridging header and a Swift probe in the app target, and annotated Objective-C headers. The Mac Development build succeeded before and after the change. The main window, Preferences, SCP, and the SSH tunnel sheet opened.

Commit `c3bdfcc` does not contain the Xcode group paths, the module settings, or the nullability edits. Those stayed unstaged. Connect, list, upload, and download were not run.

## REQUIREMENTS

- No behavior change.
- One AppKit target. No new package. No XCTest target.
- Mac `xcodebuild` of the Development configuration before any edit, and again after the move.
- Move sources. Give each Xcode group a `path`. Leave file-reference paths as filenames. Do not rewrite `#import`.
- `Info.plist` stays at the repository root.
- `PRODUCT_MODULE_NAME = Fugu`, `DEFINES_MODULE = YES`, `SWIFT_OBJC_BRIDGING_HEADER = App/Fugu-Bridging-Header.h`.
- One Swift file, `FuguSwiftBridge`, in the app target. Bridging header empty apart from the include guard.
- `NS_ASSUME_NONNULL` around methods. Real optionals, including `IBOutlet` ivars, marked `_Nullable`. C headers not wrapped in the macro.
- Do not change `CC`, `ZERO_LINK`, or `SFTPController` logic.
- Smoke: launch, preferences, SCP, tunnel sheet, then connect, list, upload, download.

## IMPLEMENTATION

### Approach

Creative phase chose group `path` plus filename file references. The target header map already lists the headers, so quoted imports survived the move. Nested group paths are the next path component only. The Images group path is `Images` because its parent path is `Resources`.

Nullability uses `NS_ASSUME_NONNULL_BEGIN` after the ivar block and `NS_ASSUME_NONNULL_END` before `@end`. `IBOutlet` ivars stay outside that claim and are `_Nullable`. The star is often glued to the name (`IBOutlet NSButton *_Nullable emailButton`). `IBAction` parameters named `sender` or `browser` that are called with nil are `_Nullable`. `remoteObjectFromSFTPLine:` returns `NSMutableDictionary * _Nullable`. `findApplicationNamed:bundleID:` returns `NSURL * _Nullable` and takes nullable arguments. `createArgv:` is `char * _Nullable * _Nullable * _Nonnull`. The two C functions in `SFTPTableView.h` have their own assume-nonnull block because they sit outside the `@interface`.

The probe is `enum FuguSwiftBridge` with `static let isEnabled = true` and no callers.

### Key components

- **Folders**: `App/`, `Core/C/`, `Core/Categories/`, `Core/Support/`, `Features/SFTP/`, `Features/SCP/`, `Features/SSHTunnel/`, `Features/Browser/`, `Resources/`, `Resources/Images/`, `Resources/en.lproj/`.
- **Groups**: SFTP `Features/SFTP`, SCP `Features/SCP`, SSHTunnel `Features/SSHTunnel`, Subclasses `Features/Browser`, Categories `Core/Categories`, Misc Classes `Core/Support`, Other Sources `Core/C`, Resources `Resources`, Images `Images`. New App group holds `main.m`, the Swift file, and the bridging header.
- **Target settings** (Development, Deployment, Default only): `DEFINES_MODULE = YES`, `PRODUCT_MODULE_NAME = Fugu`, `SWIFT_OBJC_BRIDGING_HEADER = App/Fugu-Bridging-Header.h`. Project-level configs were not given those keys.
- **Left alone**: `CC = /usr/bin/gcc`, Development `ZERO_LINK`, `SFTPController` logic, C headers `keychain.h`, `aevent.h`, `sshversion.h`, `argcargv.h`, `fdwrite.h`, `typeforchar.h`, `ODBEditorSuite.h`.

### Files

Committed in `c3bdfcc` (120 files, 9 insertions):

- Renames into the folders above, including `main.m` → `App/main.m`.
- New `App/Fugu-Bridging-Header.h` (include guard only).
- New `App/FuguSwiftBridge.swift`.

Present in the working tree and not in `c3bdfcc`:

- `Fugu.xcodeproj/project.pbxproj`: group paths, App group, Swift file in Compile Sources, and the three module settings. The same unstaged diff also contains pre-existing edits that Step 1 did not add: `Fugu Icon.icon`, `LastUpgradeCheck` 2720, `ASSETCATALOG_COMPILER_APPICON_NAME`, and `MACOSX_DEPLOYMENT_TARGET` changed from `11.5` to `$(RECOMMENDED_MACOSX_DEPLOYMENT_TARGET)` on the three target configs.
- Nullability edits on the moved Objective-C headers.
- Memory-bank updates from the build, the reflection, and this archive.

A clean checkout of `c3bdfcc` does not build. The local tree builds because the unstaged project file matches the moved files.

### Build

```text
xcodebuild -project Fugu.xcodeproj -scheme Fugu -configuration Development build
```

Xcode 27.2 (27B52), Darwin, arm64. Baseline and post-Step-1 builds both exited 0. The second log contains `SwiftCompile` of `App/FuguSwiftBridge.swift`. New nullability warnings were cleared. `iconForFileType:` deprecation warnings were already present and were left. The linker target was `arm64-apple-macos14.0` because the dirty deployment setting resolved to the recommended target. That was pre-existing.

App output: `Build/Products/Development/Fugu.app`.

### What this step did not change

No HTTP API. No database. No new data model (`RemoteEntry` is a Step 3 decision, not code). No password-path change. OpenSSH, SecItem, XIBs, and `SFTPController` logic stayed as they were. `Fugu-Swift.h` is produced by the module setting. Nothing in the app imports it yet.

## TESTING

No test target, by the Step 1 creative decision. Verification was the Mac build plus a manual UI check.

| Check | Result |
| --- | --- |
| Baseline Development build | BUILD SUCCEEDED |
| Post-move Development build | BUILD SUCCEEDED |
| `SwiftCompile` of `App/FuguSwiftBridge.swift` | Present in the log |
| New nullability warnings | Cleared |
| Launch | Main window 1175×775, title `MacBook-Air.fritz.box (localhost): disconnected`, local home listing, connect form |
| Fugu > Settings… | `Fugu Preferences: General` |
| SCP > New Secure Copy | `Secure Copy File` |
| SSH > New SSH Tunnel | `Create SSH Tunnel` |
| Connect, list, upload, download | Not run. No SSH host in the session. |

Menu proof used the accessibility tree. System Events lacked assistive access. Posting Command-comma to the process opened Preferences. Menu items were then pressed with `AXUIElementPerformAction`.

## LESSONS LEARNED

- A header map plus filename file references survives a folder move. Child group paths are one component, not the full path.
- `NS_ASSUME_NONNULL` is a behavior claim. Nil call sites, `IBOutlet` ivars, `IBAction` ids, `NSError *`, and multi-level C pointers need explicit nullability or the build warns.
- The probe belongs in the app target. An empty XCTest bundle would not prove the module.
- Do not push a `git mv` commit while `project.pbxproj` is unstaged.
- Window titles from the accessibility tree were the reliable evidence. CoreGraphics titles were empty.

## Known gaps

1. Unstaged project wiring. Commit and push `project.pbxproj` and the annotated headers before any Step 2 branch. Keep the pre-existing icon and deployment-target edits out of that commit unless they are chosen on purpose. Those edits share the same unstaged `project.pbxproj`.
2. SSH smoke: connect, list, upload, download, then quit and confirm no leftover `sftp` child from that session.

## Creative decisions preserved

The creative files stay in `memory-bank/creative/` because Steps 2–6 still depend on them.

| Decision | File | Choice |
| --- | --- | --- |
| Layout | `creative-step1-layout.md` | Move files, set group `path`, keep filenames and `#import`. `Info.plist` at the root. |
| Nullability | `creative-step1-nullability.md` | Assume nonnull on methods. `IBOutlet` ivars stay `_Nullable`. |
| Probe | `creative-step1-swift-probe.md` | `App/FuguSwiftBridge.swift` in the app target. No XCTest target. |
| Listings | `creative-listing-model.md` | Later `RemoteEntry` with a dictionary bridge. Parser stays a dictionary until Step 4. |
| Process | `creative-process-engine.md` | Keep system OpenSSH. Swift wraps the current spawn path. No SSH package. |
| Screens | `creative-ui-migration.md` | AppKit only, order browser, preferences, SCP, tunnel, main window. |
| Lifecycle | `creative-app-lifecycle.md` | `@main` after Steps 1–5. Remove the bridging header only when Swift imports no project `.h`. |

## Future

Steps 2–6 remain in `memory-bank/tasks.md`. Step 2 is blocked on the two gaps above. Step 5 needs `PRODUCT_MODULE_NAME = Fugu` from this step. Step 6 deletes the bridging header only when no project header is imported from Swift.

## REFERENCES

- Reflection: `memory-bank/reflection/reflection-step-01.md`
- Plan that was current at archive time: `memory-bank/tasks.md`
- Progress: `memory-bank/progress.md`
- Creative files listed above
- Commit: `c3bdfcc` on `migrate/step-01-project-structure-and-bridging`
