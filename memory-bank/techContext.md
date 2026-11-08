# Tech Context

## Build

- Project: `Fugu.xcodeproj/project.xcproj` (Xcode 27 project file). `last-upgrade` is `27.2`. The old `project.pbxproj` is gone.
- Configurations: Development, Deployment, Default. Every configuration sets `MACOSX_DEPLOYMENT_TARGET` to `14.0`. `SWIFT_VERSION = 6.0`.
- `PRODUCT_BUNDLE_IDENTIFIER = edu.umich.fugu`. `INFOPLIST_FILE = Info.plist`.
- Linked frameworks: Cocoa, Security, CoreServices, CoreFoundation.
- No CocoaPods, Carthage, or Swift package on disk. `audit.md` mentions KeychainAccess; that dependency is not in this tree.
- The Fugu target does not set `CC`, `CPLUSPLUS`, or `ZERO_LINK`. A shell that exports `CC=/usr/bin/gcc` still makes Xcode 27 print that explicit modules do not recognize the compiler. Unset `CC` before `xcodebuild`.
- Development host: this Mac, Xcode 27.2 (27B52), SDK MacOSX 27.2. Build with `xcodebuild -project Fugu.xcodeproj -scheme Fugu -configuration Development build`.
- The Fugu scheme currently lives only under gitignored `xcuserdata`. Share it from Xcode on the Mac if a fresh clone has no scheme.
- A user scheme named `externaleditor` points at a target that is gone. Do not build it.
- Build and run happen on this Mac. A Linux checkout has no `xcodebuild` and cannot prove the app.

## Languages and size

About 13,300 lines across the `.m`, `.h`, and `.c` files. `SFTPController.m` is the bulk of that (implementation starts at line 176 and runs past line 5400). 42 headers. No nullability annotations anywhere in source.

## Localization

Only `en.lproj` (`MainMenu.xib`, `Prefs.xib`, `SCP.xib`, `SSHTunnel.xib`). Images and `fugu.icns` live at the repository root and are grouped virtually under Resources.

## Tests

No test target, no test files. "Pass all tests" is not a safety net until a target exists.
