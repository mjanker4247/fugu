# Progress

## Done

- VAN audit and Level 4 determination.
- PLAN and CREATIVE decisions for layout, nullability, the Swift probe, listings, the process engine, screens, and `@main`.
- Mac baseline and post-Step-1 Development builds succeeded (Xcode 27.2, Darwin).
- Step 1 archived: `memory-bank/archive/archive-step-01.md`.
- Step 1 reflection: `memory-bank/reflection/reflection-step-01.md`.
- Step 2 plan confirmed on 6 Nov 2026. No new creative phase. Steps 3–6 unchanged.
- Step 2 code is on `migrate/step-02-spm-and-native-replacements`. Development build succeeded. Preview, password, and quit checks were not run.

## Not done

- Commit of the unstaged project wiring. `c3bdfcc` has the moves and the Swift probe. Group paths, module settings, and nullability are still local. The Step 2 branch was cut from that commit, so the same gap is on this branch.
- Step 1 SSH smoke: connect, list, upload, download. Preferences, SCP, and the tunnel sheet already opened.
- Step 2 manual checks: preview temp directory, password save and fill, quit cleanup of `/private/tmp/Fugu`.
- Steps 3–6. The Step 2 code is written and the Development build succeeded. It is not closed.

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

Steps 2–6 were not entered.
