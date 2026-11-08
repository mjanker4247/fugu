# Progress

## Done

- VAN and PLAN for the Xcode 27 project upgrade, 8 Nov 2026. Level 3. Disk facts, corrected during planning: `LastUpgradeCheck` is `2640`, not `2720`. All six configurations set deployment to `12.0`. `RECOMMENDED_MACOSX_DEPLOYMENT_TARGET` is `14.0`. `objectVersion` stays 54.
- Baseline Development build on Xcode 27.2 succeeded on 8 Nov 2026. The log says explicit modules are enabled but the compiler was not recognized, because `CC` is `/usr/bin/gcc`.
- Creative decision, 8 Nov 2026: deployment floor is `14.0`, not `12.0` and not `27.2`. See `memory-bank/creative/creative-xcode27-deployment.md`.
- Build, 8 Nov 2026. File: `/Users/marcojanker/development/fugu/Fugu.xcodeproj/project.pbxproj`. `LastUpgradeCheck` 2640 to 2720. Six `MACOSX_DEPLOYMENT_TARGET` values 12.0 to 14.0. Removed `CC`, `CPLUSPLUS`, and `ZERO_LINK` from the Fugu target. No source edit.
- Proof, with `CC` unset: Development `** BUILD SUCCEEDED **` (10.7s), Deployment `** BUILD SUCCEEDED **` (10.6s), Default `** BUILD SUCCEEDED **` (4.7s). Unrecognized-compiler notes: 0. A shell `CC=/usr/bin/gcc` still prints that note. `-showBuildSettings` reports `MACOSX_DEPLOYMENT_TARGET = 14.0`.
- Reflection, 8 Nov 2026: `memory-bank/reflection/reflection-xcode27.md`. The `14.0` floor compiled with no source change. The remaining explicit-modules note comes from the shell `CC`, not from the project. Archive is next.
- Archived 8 Nov 2026: `memory-bank/archive/archive-xcode27.md`. The Xcode 27 task is closed. `memory-bank/tasks.md` keeps the parked text-editor task and the Swift migration.
- Text editor setting planned on 8 Nov 2026. Level 3. That plan is parked under the Xcode 27 task in `memory-bank/tasks.md`.
- Text editor creative decision, 8 Nov 2026: a non-ODB editor opens the remote temp file and a directory watch uploads it after the file settles. ODB and CLI editors keep their current path. See `memory-bank/creative/creative-editor-launch.md`.
- Text editor implementation compiled on 8 Nov 2026. Development build succeeded. `FuguEditorCatalog` and `FuguEditorWatch` are in the app. `ODBEditors.plist` is removed. The File Editing popup, a local edit, and a remote save were not run in the app.

- VAN audit and Level 4 determination.
- PLAN and CREATIVE decisions for layout, nullability, the Swift probe, listings, the process engine, screens, and `@main`.
- Mac baseline and post-Step-1 Development builds succeeded (Xcode 27.2, Darwin).
- Step 1 archived: `memory-bank/archive/archive-step-01.md`.
- Step 1 reflection: `memory-bank/reflection/reflection-step-01.md`.
- Step 2 plan confirmed on 6 Nov 2026. No new creative phase. Steps 3–6 unchanged.
- Step 2 code is on `migrate/step-02-spm-and-native-replacements`. Development build succeeded. Preview, password, and quit checks were not run.
- Step 3 code is on `migrate/step-03-models-and-constants`. Development build succeeded on 8 Nov 2026. `RemoteEntry` round trip, date order, Gestalt packing, and a UTF-8 decode passed in a `swiftc` harness. Listing, icon, and alias smoke in the app were not run.
- Step 4's first slice is on `migrate/step-04-services-and-networking`. `FuguSSHProcess` owns the three `forkpty` calls. `UMVersionCheck` is Swift `URLSession` and `PropertyListDecoder`. Development build succeeded on 8 Nov 2026.
- Step 4's second slice, 8 Nov 2026: the same type reads each engine line with `fgets` and reaps the child with `waitpid(-1, status, 0)`. Prompt checks and `select` stay in Objective-C. `Process` was not used. Development build succeeded. Connect, cancel, upload, download, SCP, and tunnel were not run.

## Not done

- Step 1 SSH smoke: connect, list, upload, download. Preferences, SCP, and the tunnel sheet already opened.
- Step 2 manual checks: preview temp directory, password save and fill, quit cleanup of `/private/tmp/Fugu`.
- Step 3 app smoke: listing sort, icon cache, zero-size alias.
- The rest of Step 4: the prompt decisions still live in the three Objective-C loops, completion handlers are not added, and a live session is required before any `Process` switch. Steps 5 and 6 are not started.
- Step 3 and Step 4 are local. They are not committed.

## Verification

```text
uname -s → Darwin
xcodebuild -version → Xcode 27.2, build 27B52
baseline Development build → BUILD SUCCEEDED
Step 1 Development build → BUILD SUCCEEDED
SwiftCompile → App/FuguSwiftBridge.swift
launch → main window 1175×775, local listing visible
menus → Fugu Preferences: General, Secure Copy File, Create SSH Tunnel
archive → memory-bank/archive/archive-step-01.md
```

Steps 2 and 3 are implemented locally. Step 4 has the spawn, line read, reap, and the version check. The prompt decisions are still Objective-C. Steps 5 and 6 were not entered.
