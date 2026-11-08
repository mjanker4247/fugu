# TASK ARCHIVE: Upgrade the project to Xcode 27

## METADATA

- **Task ID**: xcode27
- **Complexity**: Level 3
- **Type**: Intermediate feature
- **Date completed**: 8 Nov 2026
- **Status**: COMPLETED & ARCHIVED
- **Related tasks**: Text editor setting and the Swift migration were parked and were not part of this archive. Step 1 remains in `memory-bank/archive/archive-step-01.md`.

## SUMMARY

`Fugu.xcodeproj` now builds on Xcode 27.2 (build 27B52) with an explicit macOS 14.0 deployment floor. `LastUpgradeCheck` is `2720`. The Fugu target no longer pins `CC`, `CPLUSPLUS`, or `ZERO_LINK`. Development, Deployment, and Default each succeeded. No source file changed. The app was not launched.

A shell that exports `CC=/usr/bin/gcc` still makes Xcode 27 print that explicit modules do not recognize the compiler. `/usr/bin/gcc` on this Mac is Apple clang 21.0.0. The project itself no longer sets `CC`.

## REQUIREMENTS

- `LastUpgradeCheck` is `2720`.
- The Fugu target does not set `CC`, `CPLUSPLUS`, or `ZERO_LINK`.
- All six configurations use the literal `MACOSX_DEPLOYMENT_TARGET = 14.0`. No `$(RECOMMENDED_MACOSX_DEPLOYMENT_TARGET)` macro.
- Development, Deployment, and Default each end with `** BUILD SUCCEEDED **`.
- With `CC` unset, the Development log does not say the compiler was not recognized.
- Source, the bridging header, `SWIFT_VERSION`, the Makefile, the editor catalog, and Step 4 stay untouched unless a build error names a line.

## DESIGN DECISION

Selected floor: `14.0`.

`12.0` still compiled on 8 Nov 2026 and stayed under the Xcode 27 recommendation and the platform `MinimumSDKVersion`, both `14.0`. `27.2` is the SDK version, not the recommended floor, and would have dropped every earlier Mac. The recommended macro equals `14.0` on this Xcode and can change later, so it was rejected.

Record: `memory-bank/creative/creative-xcode27-deployment.md`.

`objectVersion` stayed `54`. `compatibilityVersion` stayed `Xcode 12.0`. No Swift concurrency settings were added. `GCC_OPTIMIZATION_LEVEL = 0` on Deployment and Default was left. `LSMinimumSystemVersion` was not added to `Info.plist`.

## IMPLEMENTATION

The settings edit was made in `project.pbxproj`. Xcode 27 then rewrote the project as `Fugu.xcodeproj/project.xcproj` and removed `project.pbxproj`. The committed project file is `project.xcproj`. `last-upgrade` is `27.2`. Target and project `MACOSX_DEPLOYMENT_TARGET` are `14.0`. `CC`, `CPLUSPLUS`, and `ZERO_LINK` are absent. `.gitignore` keeps `project.xcproj`.

- `LastUpgradeCheck` `2640` → `2720`.
- `MACOSX_DEPLOYMENT_TARGET` `12.0` → `14.0` in project Development, Deployment, and Default, and in target Development, Deployment, and Default.
- Deleted `CC = /usr/bin/gcc` and `CPLUSPLUS = "/usr/bin/g++"` from the three target configurations.
- Deleted `ZERO_LINK = YES` from target Development and `ZERO_LINK = NO` from target Deployment.

No new directory. No commit was made in this task.

## TESTING

No test target. Proof is `xcodebuild -project Fugu.xcodeproj -scheme Fugu -configuration <name> build` with `CC`, `CPLUSPLUS`, and `CXX` unset.

| Configuration | Result | Unrecognized-compiler notes |
| --- | --- | --- |
| Development | `** BUILD SUCCEEDED **` (10.7s) | 0 |
| Deployment | `** BUILD SUCCEEDED **` (10.6s) | 0 |
| Default | `** BUILD SUCCEEDED **` (4.7s) | 0 |

`-showBuildSettings` for Development reports `MACOSX_DEPLOYMENT_TARGET = 14.0` and `RECOMMENDED_MACOSX_DEPLOYMENT_TARGET = 14.0`. `SDK_VERSION` is `27.2`.

The same Development build with `CC=/usr/bin/gcc` exported still prints the unrecognized-compiler note. That run also succeeded. The note is the shell, not a project setting.

The app was not launched. A live SSH session was not run.

## LESSONS LEARNED

- Re-read `project.pbxproj` at planning time. VAN had recorded `LastUpgradeCheck` `2720` and a `27.2` floor. The file had `2640` and `12.0`.
- The recommended deployment target and the SDK version are different. Here they were `14.0` and `27.2`.
- `/usr/bin/gcc` is clang on this Mac. Xcode 27 still rejects that path for explicit modules. Do not set `CLANG_ENABLE_EXPLICIT_MODULES = NO` to hide the note. Unset `CC`.

## FUTURE CONSIDERATIONS

- Delete the `PBXBuildRule` whose `compilerSpec` is `com.apple.compilers.gcc` for `sourcecode.c`. It did not cause the note once `CC` was unset.
- Raise `GCC_OPTIMIZATION_LEVEL` on Deployment and Default. Both are still `0`.
- Share the `Fugu` scheme. It still lives only under gitignored `xcuserdata`.
- Text editor in-app checks and a live Step 4 SSH session were open before this task and are still open. Step 5 was not started.

## REFERENCES

- Reflection: `memory-bank/reflection/reflection-xcode27.md`
- Creative decision: `memory-bank/creative/creative-xcode27-deployment.md`
- Build facts: `memory-bank/techContext.md`
- Product floor: `memory-bank/productContext.md` (macOS 14.0 and later)
