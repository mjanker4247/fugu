# Task Reflection: Upgrade the project to Xcode 27

## Summary

`Fugu.xcodeproj` now records an Xcode 27.2 upgrade check and builds with that toolchain's recommended deployment floor. `LastUpgradeCheck` is `2720`. All six configurations set `MACOSX_DEPLOYMENT_TARGET` to `14.0`. The Fugu target no longer sets `CC`, `CPLUSPLUS`, or `ZERO_LINK`. Development, Deployment, and Default each printed `** BUILD SUCCEEDED **` on 8 Nov 2026 when `CC` was unset. Those logs have no unrecognized-compiler note. No source file changed, and the app was not launched.

## 1. Overall outcome

The requirements in `memory-bank/tasks.md` are met. The edit stayed in `/Users/marcojanker/development/fugu/Fugu.xcodeproj/project.pbxproj`. `objectVersion` stayed 54. Swift 6, the Makefile, the bridging header, the editor catalog, and Step 4 were not touched.

One expectation from the plan was only half true. Deleting `CC` from the target does not clear the explicit-modules note if the shell still exports `CC=/usr/bin/gcc`. The project is clean. The shell is not. The proof builds unset `CC` and then showed zero notes.

Success is a settings upgrade that compiles. It is not a launch test, and it does not remove every old compiler leftover. A custom build rule still uses `com.apple.compilers.gcc` for C sources. Deployment and Default still set `GCC_OPTIMIZATION_LEVEL` to `0`. Both were left on purpose.

## 2. Planning

The plan was usable because it was rewritten against the file on disk. VAN had recorded `LastUpgradeCheck` `2720`, a project floor of `11.5`, and a target macro that it treated as macOS 27.2. PLAN re-read `project.pbxproj` and found `LastUpgradeCheck` `2640` and `12.0` in all six configurations. `RECOMMENDED_MACOSX_DEPLOYMENT_TARGET` was `14.0`. The SDK version `27.2` is not that recommendation. The corrected plan is what BUILD followed.

Scope held. No source sweep, no project-format bump, no Swift concurrency settings.

## 3. Creative phase

Flagging the deployment floor was the right call. `12.0` still compiled and would have left the project under the platform minimum. `27.2` would have matched the SDK and dropped every earlier Mac. `14.0` matched both the recommendation and `MinimumSDKVersion`.

The decision translated with no friction. All six values became the literal `14.0`. The recommended macro stayed out. Raising the floor produced no availability error, so the planned source fixes were not needed. `memory-bank/style-guide.md` did not apply. There is no UI in this change.

## 4. Implementation

The pbxproj edits were mechanical and matched the creative note. The first three builds after the edit still printed `Explicit modules is enabled but the compiler was not recognized` because this shell exports `CC=/usr/bin/gcc`. `/usr/bin/gcc` is Apple clang 21.0.0. Xcode 27 does not treat that path as its compiler for explicit modules. Rebuilding with `CC`, `CPLUSPLUS`, and `CXX` unset removed the note. `CLANG_ENABLE_EXPLICIT_MODULES` was not turned off.

## 5. Testing

There is no test target. The three configuration builds are the evidence the plan asked for. They were enough to catch the shell `CC` problem and to show that macOS 14.0 does not break this tree's compile. They do not show that the app launches, that a session still connects, or that the binary refuses macOS 12 and 13 at runtime. The plan accepted that limit. It remains a limit.

## What went well

- PLAN discarded the stale VAN numbers before any edit.
- The creative choice was one number, applied in six places, with no compile fallout.
- The explicit-modules note was traced to the environment instead of silenced with `CLANG_ENABLE_EXPLICIT_MODULES = NO`.
- Editor work and Step 4 still compiled. The settings change did not force a source fix.

## Challenges

- VAN and the file disagreed. `LastUpgradeCheck` and the deployment target were not what the first notes said. Addressed by re-reading `project.pbxproj` during PLAN and writing the plan from that read.
- The SDK default deployment property is `27.2`, while the recommended floor is `14.0`. Treating the SDK version as the deployment target would have been the wrong product cut. Addressed by using `-showBuildSettings` for `RECOMMENDED_MACOSX_DEPLOYMENT_TARGET`.
- Project `CC` was not the only `CC`. The shell export kept the note alive after the target setting was gone. Addressed by proof builds with `CC` unset, and by recording the export in `memory-bank/techContext.md`.

## Lessons learned

- On this Mac, `/usr/bin/gcc` is clang, and Xcode 27 still rejects that path for explicit modules. An exported `CC` overrides the project.
- `RECOMMENDED_MACOSX_DEPLOYMENT_TARGET` and the SDK version are different settings. Here they were `14.0` and `27.2`.
- A memory-bank claim about `LastUpgradeCheck` goes stale as soon as the pbxproj changes. The file is the source.

## Process improvements

- At the start of PLAN, re-grep `LastUpgradeCheck`, `MACOSX_DEPLOYMENT_TARGET`, `CC`, and `ZERO_LINK` and replace any VAN sentence that disagrees.
- When a compiler note survives a project edit, print the shell `CC` before changing another build setting.
- Count the proof as done only on a log produced with `CC` unset.

## Technical improvements

- Delete the `PBXBuildRule` whose `compilerSpec` is `com.apple.compilers.gcc` for `sourcecode.c` in a later build-settings pass. It did not cause this note, and it still names GCC.
- Stop shipping Deployment and Default at `GCC_OPTIMIZATION_LEVEL = 0` in that same later pass. This task left it.
- Share the `Fugu` scheme. It still lives only under gitignored `xcuserdata`.

## Next steps

- Archive this task.
- Leave Step 5 unstarted. Step 4 still needs a live SSH session. The text-editor checks in the app are still open.
- Unset `CC` in any shell that still exports `/usr/bin/gcc` before the next `xcodebuild`.
