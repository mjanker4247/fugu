# TASK REFLECTION: Step 1 project layout and bridging

## SUMMARY

Step 1 of the Fugu Objective-C to Swift migration put sources into feature folders, added an empty bridging header and `App/FuguSwiftBridge.swift`, and annotated Objective-C headers. The Mac Development build succeeded before and after the change. The main window, Preferences, SCP, and the SSH tunnel sheet opened. Connect, list, upload, and download were not run.

This reflection covers Step 1 only. Steps 2–6 have not started.

Commit `c3bdfcc` on `migrate/step-01-project-structure-and-bridging` contains the file moves and the two new App files. The Xcode group paths, module settings, and nullability edits were still unstaged when that commit was pushed.

## System Overview

### System Description

Fugu 1.2.1b is one AppKit target. Step 1 does not change transfer behavior. It makes the tree match the features that already exist and proves the target can compile Swift.

### System Context

The app browses a local folder and a remote SFTP folder, copies with SCP, and opens SSH tunnels. OpenSSH stays the engine. The Mac with Xcode is the only build host.

### Key Components

- Folder layout: `App/`, `Core/C/`, `Core/Categories/`, `Core/Support/`, `Features/SFTP/`, `Features/SCP/`, `Features/SSHTunnel/`, `Features/Browser/`, `Resources/`.
- Interop: `PRODUCT_MODULE_NAME = Fugu`, `DEFINES_MODULE = YES`, `SWIFT_OBJC_BRIDGING_HEADER = App/Fugu-Bridging-Header.h`.
- Probe: `enum FuguSwiftBridge` with no callers.
- Nullability: `NS_ASSUME_NONNULL` around methods, `_Nullable` on `IBOutlet` ivars and on values that are actually nil.

### System Architecture

Creative phase selected group `path` plus filename file references. `#import` lines stayed unchanged. `Info.plist` stayed at the repository root. C headers stayed on `_Nullable` / `_Nonnull`. No XCTest target.

### System Boundaries

XIB outlets, the Services `secureCopyFile` action, SecItem keychain items, `/private/tmp/Fugu`, ODB Apple Events, and the version-check URL were not rewritten. `CC` and `ZERO_LINK` were not changed.

### Implementation Summary

Baseline `xcodebuild` on Darwin with Xcode 27.2 succeeded. Files were moved with `git mv`. The same Development build succeeded after the move and again after nullability warnings were cleared. Launch used `Build/Products/Development/Fugu.app`.

## WHAT WENT WELL

- The Mac gate was real. The earlier Linux attempt stopped instead of pretending a build.
- Option B held. Quoted imports still resolved through the target header map. `USER_HEADER_SEARCH_PATHS` was not needed.
- `SwiftCompile` of `App/FuguSwiftBridge.swift` appeared in the log, so the module and bridging header are wired in the working tree.
- The main window listed the local home folder next to the connect form. Preferences opened as `Fugu Preferences: General`. SCP opened as `Secure Copy File`. The tunnel command opened `Create SSH Tunnel`.
- Nullability warnings were treated as a failed Step 1 and cleared without changing `SFTPController` logic.
- Pre-existing `iconForFileType:` deprecations were left alone.

## CHALLENGES

1. **Staged commit lagged the working tree.** `c3bdfcc` records renames and the two new files. Group paths, `PRODUCT_MODULE_NAME`, `DEFINES_MODULE`, the bridging-header setting, and the header annotations were unstaged. A checkout of that commit does not build the Step 1 tree the Mac just compiled.
   - Outcome: the push is a partial Step 1.
   - Preventative measure: stage `project.pbxproj` and the annotated headers in the same commit as the moves, or do not push until `git status` is clean of Step 1 edits.

2. **`IBOutlet` stars sit against the name.** The first annotator required whitespace between `*` and the ivar. Lines such as `IBOutlet NSButton *emailButton` were skipped. A second pass inserted `_Nullable` before the name.
   - Outcome: outlets are `_Nullable`.
   - Preventative measure: match both `*name` and `* name`.

3. **Assume-nonnull disagreed with nil call sites and with AppKit overrides.** Methods called with `nil`, `setImage:`, and `setDelegate:` became nonnull and warned. `IBAction` parameters named `browser` were missed because the first pattern only rewrote `sender`. `char ***` needed a nullability specifier on each star.
   - Outcome: those declarations were marked to match actual nil use and the SDK.
   - Preventative measure: after the first annotated build, fix every `-Wnullability` and `-Wnonnull` before calling the step done.

4. **Menu automation.** System Events refused assistive access. App-target keystrokes did not open Preferences. Posting Command-comma to the process pid did. Menu items were then pressed through the accessibility tree.
   - Outcome: the three windows opened. The SSH transfer checklist did not.
   - Preventative measure: drive Fugu menus through `AXUIElementPerformAction`, and keep a host for the transfer check.

5. **Dirty Xcode settings were already in the tree.** The baseline ran with an uncommitted deployment-target change and an icon reference. Step 1 did not add them and did not revert them.
   - Outcome: the successful build is not a clean `master` build.
   - Preventative measure: record the dirty baseline, and keep those edits out of the migration commit unless they are intentional.

## LESSONS LEARNED

- A header map plus a Headers build phase survives a folder move when file references stay filenames and each group gets one `path`. Nested `Images` must be `Images`, not `Resources/Images`, because the parent group path is `Resources`.
- `NS_ASSUME_NONNULL` is a behavior claim. Every existing `nil` argument and every AppKit override that is already nullable has to be marked, or the build warns.
- `init` stays implicitly nullable under assume-nonnull. Listing parsers that `return nil` do not. `remoteObjectFromSFTPLine:` and `findApplicationNamed:bundleID:` needed explicit `_Nullable`.
- The probe belongs in the app target. An empty XCTest bundle would not have proved `Fugu-Swift.h`.
- Window titles from CoreGraphics were empty. The accessibility title was the evidence: `Fugu Preferences: General`, `Secure Copy File`, `Create SSH Tunnel`.

## PROCESS IMPROVEMENTS

- Do not push a move commit while `project.pbxproj` is still unstaged.
- Split "implementation built locally" from "implementation is on the branch." Step 1 is the first, not the second.
- Keep the SSH smoke as its own checkbox. Do not mark the step closed because the windows opened.
- Reflect per migration step. Do not wait for Steps 2–6 to record what Step 1 taught.

## TECHNICAL IMPROVEMENTS

- Commit the unstaged `project.pbxproj` and header annotations before any Step 2 branch.
- On the next annotate pass, cover `*name`, every `IBAction` id parameter, `NSError *`, and multi-level C pointers in one script, then rebuild once.
- Leave `iconForFileType:` until a step that is allowed to change call sites.
- Add `USER_HEADER_SEARCH_PATHS` only if a later move reports a missing header. Do not add it preemptively.

## Project Performance Analysis

### Timeline Performance

- Planned duration was not estimated in days.
- Actual Step 1 build and UI check happened on 5–6 Nov 2026, after planning earlier the same night.
- Variance is not a schedule slip. The Linux build stop was the plan working.

### Resource Utilization

One Mac checkout, Xcode 27.2, no new package.

### Quality Metrics

- Planned: Development `xcodebuild` exits 0, the app launches, imports unchanged, no new nullability warnings.
- Achieved locally: build succeeded, launch and three auxiliary windows succeeded, imports unchanged, nullability warnings cleared.
- Not achieved: SSH connect, list, upload, download. The pushed commit lacks the project file that makes the move compile.

### Risk Management Effectiveness

- Predicted risk that a Linux build would not count: avoided.
- Predicted risk that a folder move breaks includes: did not occur.
- Predicted risk that outlets marked nonnull would lie: avoided by leaving ivars outside assume-nonnull and marking them `_Nullable`.
- Unforeseen: the commit action published only the index, so the wiring stayed local.

## Technical Insights

### Architecture Insights

- Group path is relative to the parent. `Resources` + `Images` is the on-disk `Resources/Images`.
- Context: the Images group is nested under Resources.
- Implication: a literal path of `Resources/Images` on the child would look for `Resources/Resources/Images`.
- Recommendation: keep child paths as the next path component only.

### Implementation Insights

- The Headers build phase, not rewritten imports, is what made the move safe.
- Context: the post-move build succeeded with no search-path change.
- Implication: Step 5 XIB module names are the next place paths can break, not `#import` lines.
- Recommendation: change `PRODUCT_MODULE_NAME` consumers only when a XIB custom class fails to load.

### Technology Stack Insights

- `CC = /usr/bin/gcc` still invokes the Xcode 27.2 clang for this project. Nullability macros were accepted.
- Context: the Development link line used the XcodeDefault toolchain.
- Implication: do not "fix" `CC` in a later step unless a compiler error requires it.
- Recommendation: leave `CC` and `ZERO_LINK` until a dedicated build-settings change after a clean baseline.

### Performance Insights

- The second Development build finished in about 2 seconds because almost nothing recompiled.
- Context: nullability edits were header-only after the move had already compiled.
- Implication: header annotation cost shows up as warnings, not as a long rebuild.
- Recommendation: read the warning list. Do not treat a fast incremental build as proof that annotations are quiet.

### Security Insights

- Step 1 did not move passwords, keychain calls, or the OpenSSH spawn path.
- Context: `keychain.c` moved into `Core/C/` and stayed C.
- Implication: SecItem behavior is unchanged.
- Recommendation: the password round-trip stays a Step 2 check, not a Step 1 claim.

## Process Insights

### Planning Insights

- Writing the Mac command into `tasks.md` before `/build` made the Linux stop obvious.
- Recommendation: keep the next step's smoke command in the same file before the edit.

### Development Process Insights

- `git mv` staged the renames. Later header edits and the `pbxproj` edit did not join that index.
- Recommendation: one `git status` after the successful build, then one commit of every Step 1 path.

### Testing Insights

- There is still no test target, by the creative decision. The smoke list is the test.
- Recommendation: do not add XCTest until the listing parser is a pure function.

### Collaboration Insights

- The cloud worker planned. The Mac built. Mixing those trees without a commit of the project file splits the truth.
- Recommendation: the Mac branch is the source of truth after the first successful `xcodebuild`.

### Documentation Insights

- `tasks.md` still describes both the Linux stop and the Mac result. That history is useful. The status checkboxes are the current truth.
- Recommendation: when archiving, keep the build log and drop the "Linux workspace" wording from the current-focus file.

## Business Insights

### Value Delivery Insights

- Users see the same dual-pane window. The value of Step 1 is that later Swift edits have a module name and a folder map.
- Business impact: none until a later step changes a screen or a transfer.
- Recommendation: do not announce a Swift port from Step 1.

### Stakeholder Insights

- The only check a person still has to do is an SSH session: connect, list, upload, download.
- Recommendation: that check blocks Step 2. It does not require another planning pass.

### Market/User Insights

- The English XIBs still contain a few German menu titles (`Lokale Ansicht aktivieren`, `Serveransicht aktivieren`). Step 1 did not touch them.
- Recommendation: treat string cleanup as separate from the Swift move.

### Business Process Insights

- A partial push looks finished in GitHub and is unfinished in Xcode.
- Recommendation: the next push of this branch should be the project file and the annotations, with a message that says the previous commit did not build by itself.

## Strategic Actions

### Immediate Actions

- Commit the unstaged Step 1 wiring: `Fugu.xcodeproj/project.pbxproj` and the annotated headers. Leave user scheme state, `.cursor/`, `.agents/`, and the untracked icon files out unless they are chosen on purpose.
  - Owner: the Mac checkout.
  - Success criteria: a clean build of that commit, not only of the dirty tree.
  - Priority: high.

- Run connect, list, upload, and download against one SSH host.
  - Owner: the person who has the host.
  - Success criteria: those four actions finish and quit leaves no extra `sftp` child from that session.
  - Priority: high.

### Short-Term Improvements (1-3 months)

- Step 2: `NSFileManager(mktemp)` call sites and a small SecItem wrapper, still on the Mac, still one branch.
  - Success criteria: Development build, and a password save/fill.
  - Priority: medium. Blocked on the two immediate actions.

### Medium-Term Initiatives (3-6 months)

- Steps 3–5 as already written: models, then the OpenSSH process wrapper, then one screen per branch. `SFTPController` stays last.
  - Priority: medium.

### Long-Term Strategic Directions (6+ months)

- Step 6 replaces `main.m` with `@main` and deletes the bridging header only when no project header is imported from Swift.
  - Expected impact: one Swift AppKit target, same OpenSSH behavior.
  - Key milestone: the last `.m` is gone and the Mac smoke list passes.

## Knowledge Transfer

### Key Learnings for Organization

- For this repo, a folder move is safe when the header map already lists the headers and file references stay filenames.
- Applicability: any later move of the same target.
- Where it lives: this file and `memory-bank/creative/creative-step1-layout.md`.

### Technical Knowledge Transfer

- Nullability exceptions are the nil call sites, `IBOutlet` ivars, `IBAction` ids, `NSError *`, `remoteObjectFromSFTPLine:`, and `findApplicationNamed:bundleID:`.
- Audience: the next edit of those headers.
- Documentation: the headers themselves and `memory-bank/creative/creative-step1-nullability.md`.

### Process Knowledge Transfer

- Build on the Mac. Push only a tree that contains `project.pbxproj` for that move.
- Audience: the next `/build`.
- Documentation: `memory-bank/tasks.md` build log.

### Documentation Updates

- `memory-bank/tasks.md` status now records this reflection. Archive is still open.
- `memory-bank/activeContext.md` should keep the unstaged-wiring fact until that commit exists.

## Reflection Summary

### Key Takeaways

- The layout decision worked on the Mac build.
- The Swift probe compiled in the app target.
- The published commit is not that build.

### Success Patterns to Replicate

1. Baseline `xcodebuild` before the first migration edit.
2. Creative option written as path rules, then one move, then one rebuild.
3. Nullability warnings fail the step until they are gone.

### Issues to Avoid in Future

1. Pushing `git mv` while the project file is unstaged.
2. Assuming `sender` is the only `IBAction` parameter name.
3. Calling Step 1 done before an SSH connect, list, upload, and download.

### Overall Assessment

Step 1 did the structural job it was planned to do, and the Mac app still opens. It is not a closed step. The branch on GitHub lacks the project wiring, and the transfer smoke has no host result.

### Next Steps

1. Commit and push the unstaged `project.pbxproj` and header annotations.
2. Repeat the Development build from that commit.
3. Run the SSH smoke.
4. Then `/archive` this step, and start Step 2 on a new branch.
